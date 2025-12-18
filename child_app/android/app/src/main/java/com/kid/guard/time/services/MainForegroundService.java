package com.kid.guard.time.services;

import android.Manifest;
import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.SetOptions;
import com.kid.guard.time.MainActivity;
import com.kid.guard.time.R;
import com.kid.guard.time.activities.BlockedAppActivity;
import com.kid.guard.time.models.App;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainForegroundService extends Service {
	public static final int NOTIFICATION_ID = 27;
	public static final String TAG = "MainServiceTAG";
	public static final String BLOCKED_APP_NAME_EXTRA = "BLOCKED_APP_NAME_EXTRA";
	public static final String CHANNEL_ID = "ChildAppChannel";
    
	private ExecutorService executorService;
	private ArrayList<App> apps;
    private List<Map<String, Object>> policyApps;
	private String uid;
    private String deviceId;
	private FirebaseFirestore db = FirebaseFirestore.getInstance();
	private DocumentReference deviceRef;
	
	@Override
	public void onCreate() {
		super.onCreate();
        createNotificationChannel();
		executorService = Executors.newSingleThreadExecutor();
		LockerThread thread = new LockerThread();
		executorService.submit(thread);
	}
	
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Child App Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }
        }
    }

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		FirebaseAuth auth = FirebaseAuth.getInstance();
		FirebaseUser user = auth.getCurrentUser();
		if (user != null) {
		    uid = user.getUid();
        } else {
            // Wait for login or stop? For now we run, but logic won't work without UID.
            Log.w(TAG, "No user logged in yet");
        }

        // Persistent Device ID
        SharedPreferences prefs = getSharedPreferences("DevicePrefs", MODE_PRIVATE);
        deviceId = prefs.getString("device_id", null);
        if (deviceId == null) {
            deviceId = "android_" + System.currentTimeMillis();
            prefs.edit().putString("device_id", deviceId).apply();
        }
		
		Intent notificationIntent = new Intent(this, MainActivity.class);
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
		
		Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
				.setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Child Mode Active")
                .setContentText("Monitoring device usage...")
                .setContentIntent(pendingIntent).build();
		
		startForeground(NOTIFICATION_ID, notification);
		
        if (uid != null) {
             deviceRef = db.collection("users").document(uid).collection("devices").document(deviceId);
             registerDevice();
             listenForPolicy();
             // uploadContacts(); 
             // getUserLocation(); 
        }

		return START_STICKY;
	}

    private void registerDevice() {
        Map<String, Object> deviceData = new HashMap<>();
        deviceData.put("id", deviceId);
        deviceData.put("name", Build.MODEL);
        deviceData.put("type", "android");
        deviceRef.set(deviceData, SetOptions.merge());
    }
    
    private void listenForPolicy() {
		deviceRef.addSnapshotListener(new EventListener<DocumentSnapshot>() {
            @Override
            public void onEvent(@Nullable DocumentSnapshot snapshot, @Nullable FirebaseFirestoreException e) {
                if (e != null) return;
                if (snapshot != null && snapshot.exists()) {
                    parseDeviceSnapshot(snapshot);
                }
            }
        });
    }

    private void parseDeviceSnapshot(DocumentSnapshot snapshot) {
          Map<String, Object> data = snapshot.getData();
          if (data == null) return;
          if (data.containsKey("policy")) {
              Object policyObj = data.get("policy");
              if (policyObj instanceof Map) {
                  Map<String, Object> policy = (Map<String, Object>) policyObj;
                  if (policy.containsKey("applications")) {
                      Object appsObj = policy.get("applications");
                      if (appsObj instanceof List) {
                         policyApps = (List<Map<String, Object>>) appsObj;
                      }
                  }
              }
          }
    }
	
	@Override
	public void onDestroy() {
		super.onDestroy();
		if (executorService != null) {
			executorService.shutdown();
		}
	}
	
	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}
	
	public String getTopAppPackageName() {
		String appPackageName = "";
		try {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				UsageStatsManager usageStatsManager = (UsageStatsManager) this.getSystemService(USAGE_STATS_SERVICE);
                long milliSecs = 60 * 1000;
                Date date = new Date();
                List<UsageStats> foregroundApps = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, date.getTime() - milliSecs, date.getTime());
                long recentTime = 0;
                for (UsageStats stats : foregroundApps) {
                    if (stats.getLastTimeStamp() > recentTime) {
                        recentTime = stats.getLastTimeStamp();
                        appPackageName = stats.getPackageName();
                    }
                }
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return appPackageName;
	}
	
	class LockerThread implements Runnable {
		private Intent intent = null;
		public LockerThread() {
			intent = new Intent(MainForegroundService.this, BlockedAppActivity.class);
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		}
		@Override
		public void run() {
			while (true) {
				if (policyApps != null) {
					String foregroundAppPackageName = getTopAppPackageName();
					for (Map<String, Object> polApp : policyApps) {
                        String pkgName = (String) polApp.get("packageName");
                        Object blockedObj = polApp.get("isBlocked");
                        boolean isBlocked = false;
                        if (blockedObj instanceof Boolean) isBlocked = (Boolean) blockedObj;
                        
						if (pkgName != null && pkgName.equals(foregroundAppPackageName) && isBlocked) {
							startActivity(intent);
                            break; 
						}
					}
				}
				try {
					Thread.sleep(1000); 
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
