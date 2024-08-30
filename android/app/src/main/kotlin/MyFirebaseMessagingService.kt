package com.example.my_new_app

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // Handle the message here
        Log.d("FCM", "Message received: ${remoteMessage.data}")
    }

    override fun onNewToken(token: String) {
        Log.d("FCM", "Refreshed token: $token")
        // You might want to send the token to your server here
    }
}
