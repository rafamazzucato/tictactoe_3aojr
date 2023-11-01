package com.example.tictactoe_3aojr

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.util.Log
import com.google.gson.JsonElement
import com.pubnub.api.PNConfiguration
import com.pubnub.api.PubNub
import com.pubnub.api.callbacks.SubscribeCallback
import com.pubnub.api.models.consumer.PNStatus
import com.pubnub.api.models.consumer.objects_api.channel.PNChannelMetadataResult
import com.pubnub.api.models.consumer.objects_api.membership.PNMembershipResult
import com.pubnub.api.models.consumer.objects_api.uuid.PNUUIDMetadataResult
import com.pubnub.api.models.consumer.pubsub.PNMessageResult
import com.pubnub.api.models.consumer.pubsub.PNPresenceEventResult
import com.pubnub.api.models.consumer.pubsub.PNSignalResult
import com.pubnub.api.models.consumer.pubsub.files.PNFileEventResult
import com.pubnub.api.models.consumer.pubsub.message_actions.PNMessageActionResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Arrays

class MainActivity: FlutterActivity() {

    private val METHOD_CHANNEL = "game/exchange"

    private var channel_pubNub: String? = null
    private var pubNub: PubNub? = null
    private var handler: Handler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        handler = Handler(Looper.getMainLooper())

        val pnConfiguration = PNConfiguration("MyUniqueUUID")
        pnConfiguration.subscribeKey = "sub-c-c84cf3ae-c7da-49d5-a044-c3b55b84bed9"
        pnConfiguration.publishKey = "pub-c-8290cf60-30c1-4e75-bdb7-b3ac46a0282b"

        pubNub = PubNub(pnConfiguration)

        pubNub.let {
            it?.addListener( object : SubscribeCallback(){
                override fun status(pubnub: PubNub, pnStatus: PNStatus) {}
                override fun presence(pubnub: PubNub, pnPresenceEventResult: PNPresenceEventResult) {}
                override fun signal(pubnub: PubNub, pnSignalResult: PNSignalResult) {}
                override fun uuid(pubnub: PubNub, pnUUIDMetadataResult: PNUUIDMetadataResult) {}
                override fun channel(pubnub: PubNub, pnChannelMetadataResult: PNChannelMetadataResult) {}
                override fun membership(pubnub: PubNub, pnMembershipResult: PNMembershipResult) {}
                override fun messageAction(pubnub: PubNub, pnMessageActionResult: PNMessageActionResult) {}
                override fun file(pubnub: PubNub, pnFileEventResult: PNFileEventResult) {}

                override fun message(pubnub: PubNub, pnMessageResult: PNMessageResult) {
                    Log.d("Pubnub Listener", "Received Mesage: R{pnMessageResult.message.toString()}")
                    var receivedObject: JsonElement? = null
                    var actionReceived = "sendAction"

                    if(pnMessageResult.message.asJsonObject["tap"] !== null){
                        receivedObject = pnMessageResult.message.asJsonObject["tap"]
                    }

                    handler?.let {
                        it.post {
                            val methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, METHOD_CHANNEL)
                            methodChannel.invokeMethod(actionReceived, receivedObject.toString())
                        }
                    }
                }
            })
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            if(call.method == "sendAction"){
                pubNub!!.publish()
                        .message(call.arguments)
                        .channel(channel_pubNub)
                        .async { _, status -> Log.d("pubnub", "teve erro? ${status.isError}")}
                result.success(true)
            }
            else if(call.method == "subscribe"){
                subscribeChannel(call.argument<String>("channel"))
                result.success(true)
            }
        }
    }

    fun subscribeChannel(channelName: String?){
        channel_pubNub = channelName
        channelName.let {
            pubNub?.subscribe()?.channels(Arrays.asList(channelName))?.execute()
        }
    }
}
