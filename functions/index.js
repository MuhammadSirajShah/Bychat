
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const crypto = require("node:crypto");

initializeApp();

const db = getFirestore();

function normalizePhoneNumber(value) {
  if (typeof value !== "string") {
    return "";
  }

  let phone = value.replace(/[^\d+]/g, "");

  if (phone.startsWith("+")) {
    phone = phone.substring(1);
  }

  if (phone.startsWith("0092")) {
    phone = phone.substring(2);
  } else if (phone.startsWith("0") && phone.length === 11) {
    phone = `92${phone.substring(1)}`;
  }

  // Store phone numbers in normalized international format.
  if (!/^\d{8,15}$/.test(phone)) {
    return "";
  }

  return phone;
}

function phoneHash(phone) {
  return crypto
    .createHash("sha256")
    .update(phone)
    .digest("hex");
}

function requireSignedIn(request) {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Please sign in to ByChat."
    );
  }
}

exports.updateContactLookup = onCall(async (request) => {
  requireSignedIn(request);

  const uid = request.auth.uid;
  const verifiedPhone = request.auth.token.phone_number;

  if (typeof verifiedPhone !== "string" || !verifiedPhone.startsWith("+")) {
    throw new HttpsError(
      "failed-precondition",
      "A verified phone number is required."
    );
  }

  const normalizedPhone = normalizePhoneNumber(verifiedPhone);

  if (!normalizedPhone) {
    throw new HttpsError(
      "failed-precondition",
      "The verified phone number is invalid."
    );
  }

  const userRef = db.collection("users").doc(uid);
  const userSnapshot = await userRef.get();

  if (!userSnapshot.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Save your profile before updating contact lookup."
    );
  }

  const userData = userSnapshot.data();

  const lookupRef = db
    .collection("contactLookup")
    .doc(phoneHash(normalizedPhone));

  await lookupRef.set({
    uid,
    name: userData.name || "",
    username: userData.username || "",
    photoUrl: userData.photoUrl || "",
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

exports.findByChatContacts = onCall(async (request) => {
  requireSignedIn(request);

  const phones = request.data?.phoneNumbers;

  if (!Array.isArray(phones) || phones.length > 200) {
    throw new HttpsError(
      "invalid-argument",
      "Provide a list of up to 200 phone numbers."
    );
  }

  const uniquePhones = [
    ...new Set(
      phones
        .map(normalizePhoneNumber)
        .filter((phone) => phone.length > 0)
    ),
  ];

  const currentUid = request.auth.uid;
  const results = [];

  // Process in batches to keep the number of simultaneous reads small.
  for (const phone of uniquePhones) {
    const lookupSnapshot = await db
      .collection("contactLookup")
      .doc(phoneHash(phone))
      .get();

    if (!lookupSnapshot.exists) {
      continue;
    }

    const data = lookupSnapshot.data();

    // Never return the current user's own contact.
    if (!data.uid || data.uid === currentUid) {
      continue;
    }

    results.push({
      uid: data.uid,
      name: data.name || "",
      username: data.username || "",
      photoUrl: data.photoUrl || "",
      phoneNumber: `+${phone}`,
    });
  }

  return { contacts: results };
});
