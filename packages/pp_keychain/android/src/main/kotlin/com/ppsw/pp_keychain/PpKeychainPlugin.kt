package com.ppsw.pp_keychain

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** PpKeychainPlugin */
class PpKeychainPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val keyStoreAlias = "pp_keychain_key"
    private val sharedPreferencesName = "com.mobiunity.apps.shared_prefs"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pp_keychain")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "save" -> {
                handleSave(call, result)
            }
            "read" -> {
                handleRead(call, result)
            }
            "delete" -> {
                handleDelete(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleSave(call: MethodCall, result: Result) {
        val key = call.argument<String>("key")
        val value = call.argument<String>("value")
        
        if (key == null || value == null) {
            result.success(false)
            return
        }
        
        try {
            val encryptedValue = encrypt(value)
            val sharedPreferences = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
            sharedPreferences.edit().putString(key, encryptedValue).apply()
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun handleRead(call: MethodCall, result: Result) {
        val key = call.argument<String>("key")
        
        if (key == null) {
            result.success(null)
            return
        }
        
        try {
            val sharedPreferences = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
            val encryptedValue = sharedPreferences.getString(key, null)
            
            if (encryptedValue == null) {
                result.success(null)
                return
            }
            
            val decryptedValue = decrypt(encryptedValue)
            result.success(decryptedValue)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(null)
        }
    }

    private fun handleDelete(call: MethodCall, result: Result) {
        val key = call.argument<String>("key")
        
        if (key == null) {
            result.success(false)
            return
        }
        
        try {
            val sharedPreferences = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
            sharedPreferences.edit().remove(key).apply()
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun getSecretKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        
        if (!keyStore.containsAlias(keyStoreAlias)) {
            val keyGenerator = KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES,
                "AndroidKeyStore"
            )
            
            val keyGenParameterSpec = KeyGenParameterSpec.Builder(
                keyStoreAlias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setUserAuthenticationRequired(false)
                .build()
            
            keyGenerator.init(keyGenParameterSpec)
            return keyGenerator.generateKey()
        }
        
        val secretKeyEntry = keyStore.getEntry(keyStoreAlias, null) as KeyStore.SecretKeyEntry
        return secretKeyEntry.secretKey
    }

    private fun encrypt(value: String): String {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, getSecretKey())
        val iv = cipher.iv
        val encryptedBytes = cipher.doFinal(value.toByteArray())
        val combined = iv + encryptedBytes
        return Base64.encodeToString(combined, Base64.DEFAULT)
    }

    private fun decrypt(encryptedValue: String): String {
        val combined = Base64.decode(encryptedValue, Base64.DEFAULT)
        val iv = combined.copyOfRange(0, 12)
        val encryptedBytes = combined.copyOfRange(12, combined.size)
        
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        val spec = GCMParameterSpec(128, iv)
        cipher.init(Cipher.DECRYPT_MODE, getSecretKey(), spec)
        
        val decryptedBytes = cipher.doFinal(encryptedBytes)
        return String(decryptedBytes)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
