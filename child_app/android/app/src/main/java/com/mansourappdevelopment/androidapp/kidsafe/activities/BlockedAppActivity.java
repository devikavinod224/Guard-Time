package com.mansourappdevelopment.androidapp.kidsafe.activities;

import android.app.Activity;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.TextView;

public class BlockedAppActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        TextView textView = new TextView(this);
        textView.setText("THIS APP IS BLOCKED BY PARENT");
        textView.setTextSize(24f);
        textView.setTextColor(0xFFFF0000); // Red
        textView.setGravity(Gravity.CENTER);
        textView.setBackgroundColor(0xFFFFFFFF); // White bg

        setContentView(textView);
    }
    
    @Override
    public void onBackPressed() {
        // Do nothing to prevent leaving? 
        // Or minimize?
        moveTaskToBack(true);
    }
}
