package com.n2bbrasil.marketingcloudsf_example;

import android.os.Bundle;
import android.os.PersistableBundle;

import androidx.annotation.Nullable;

import com.google.firebase.FirebaseApp;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);
        FirebaseApp.initializeApp(this);
    }
}
