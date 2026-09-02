const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * 📦 Trigger 1: Send Push Notification to Customer when Admin Updates Order Status
 * Triggers on Firestore document update: orders/{orderId}
 */
exports.onOrderStatusUpdated = onDocumentUpdated("orders/{orderId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  // If status has not changed, exit early
  if (beforeData.status === afterData.status) {
    console.log(`Order ${event.params.orderId} updated, but status remains: ${afterData.status}`);
    return null;
  }

  const orderId = event.params.orderId;
  const userId = afterData.userId;
  const newStatus = afterData.status;

  console.log(`Order ${orderId} status changed from "${beforeData.status}" to "${newStatus}" for user: ${userId}`);

  if (!userId || userId === "guest") {
    console.log("No valid user ID attached to order. Skipping notification.");
    return null;
  }

  try {
    // 1. Fetch user document from Firestore to get device FCM token
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.log(`User document ${userId} not found.`);
      return null;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log(`User ${userId} does not have a registered FCM token.`);
      return null;
    }

    // 2. Construct FCM Notification payload
    const shortOrderId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    const message = {
      token: fcmToken,
      notification: {
        title: "Order Status Update 🚚",
        body: `Your order #${shortOrderId} status has been updated to "${newStatus}".`,
      },
      data: {
        orderId: orderId,
        status: newStatus,
        route: "/home",
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "high_importance_channel",
        },
      },
    };

    // 3. Send FCM Message via Firebase Admin SDK
    const response = await admin.messaging().send(message);
    console.log(`Successfully sent order update notification to user ${userId}:`, response);
    return response;
  } catch (error) {
    console.error("Error sending order status push notification:", error);
    return null;
  }
});

/**
 * 🛒 Trigger 2: Send Broadcast Push Notification to All Users when a New Product is Added
 * Triggers on Firestore document creation: products/{productId}
 */
exports.onNewProductAdded = onDocumentCreated("products/{productId}", async (event) => {
  const newProduct = event.data.data();
  const productName = newProduct.name || "New Grocery Product";
  const price = newProduct.price ? `$${newProduct.price}` : "";

  console.log(`New product created: ${productName} (${price})`);

  try {
    // Construct Broadcast Notification Payload to topic 'all_users'
    const message = {
      topic: "all_users",
      notification: {
        title: "New Item Alert! 🛒",
        body: `${productName} ${price} is now available in Nectar Store!`,
      },
      data: {
        productId: event.params.productId,
        route: "/home",
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log("Successfully sent new product broadcast notification:", response);
    return response;
  } catch (error) {
    console.error("Error sending new product broadcast notification:", error);
    return null;
  }
});
