// Ravza Wear OS App — MVP (Compose + Wearable MessageClient)
// Tek buton: her dokunusta telefona "/ravza-dhikr" mesaji gonderir.
package com.ibrahimaktas.ravza.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.google.android.gms.wearable.Wearable

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var count by remember { mutableStateOf(0) }
            Column(
                Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("$count", style = MaterialTheme.typography.display1)
                Spacer(Modifier.height(8.dp))
                Button(onClick = {
                    count++
                    sendDhikr()
                }) { Text("Zikir Çek") }
            }
        }
    }
    private fun sendDhikr() {
        val client = Wearable.getMessageClient(this)
        Wearable.getNodeClient(this).connectedNodes.addOnSuccessListener { nodes ->
            for (node in nodes) {
                client.sendMessage(node.id, "/ravza-dhikr", byteArrayOf(1))
            }
        }
    }
}
