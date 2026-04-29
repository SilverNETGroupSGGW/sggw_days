const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const BROADCAST_CHANNEL_ID = 'event_broadcasts';

exports.sendNotificationBroadcast = onDocumentCreated(
  'notification_broadcasts/{broadcastId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const broadcast = snapshot.data();
    const title = typeof broadcast.title === 'string' ? broadcast.title.trim() : '';
    const body = typeof broadcast.body === 'string' ? broadcast.body.trim() : '';

    if (!title || !body || broadcast.status !== 'queued') {
      await snapshot.ref.update({
        status: 'rejected',
        error: 'Invalid broadcast payload',
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const tokenSnapshot = await db
      .collection('notification_tokens')
      .where('enabled', '==', true)
      .get();

    const tokens = tokenSnapshot.docs
      .map((doc) => ({ id: doc.id, token: doc.get('token') }))
      .filter((entry) => typeof entry.token === 'string' && entry.token.length > 0);

    if (tokens.length === 0) {
      await snapshot.ref.update({
        status: 'sent',
        sentCount: 0,
        failedCount: 0,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    let sentCount = 0;
    let failedCount = 0;
    const invalidTokenDocIds = [];

    for (let index = 0; index < tokens.length; index += 500) {
      const chunk = tokens.slice(index, index + 500);
      const response = await admin.messaging().sendEachForMulticast({
        tokens: chunk.map((entry) => entry.token),
        notification: { title, body },
        android: {
          notification: {
            channelId: BROADCAST_CHANNEL_ID,
          },
        },
        data: {
          broadcastId: event.params.broadcastId,
          type: 'admin_broadcast',
        },
      });

      sentCount += response.successCount;
      failedCount += response.failureCount;

      response.responses.forEach((sendResponse, responseIndex) => {
        if (sendResponse.success) return;
        const code = sendResponse.error && sendResponse.error.code;
        if (
          code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token' ||
          code === 'messaging/invalid-argument'
        ) {
          invalidTokenDocIds.push(chunk[responseIndex].id);
        }
      });
    }

    const batch = db.batch();
    invalidTokenDocIds.forEach((docId) => {
      batch.update(db.collection('notification_tokens').doc(docId), {
        enabled: false,
        disabledAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    batch.update(snapshot.ref, {
      status: 'sent',
      sentCount,
      failedCount,
      invalidTokenCount: invalidTokenDocIds.length,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();

    logger.info('Notification broadcast sent', {
      broadcastId: event.params.broadcastId,
      sentCount,
      failedCount,
      invalidTokenCount: invalidTokenDocIds.length,
    });
  },
);
