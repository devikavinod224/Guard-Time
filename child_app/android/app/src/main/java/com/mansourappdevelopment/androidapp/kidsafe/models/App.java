package com.mansourappdevelopment.androidapp.kidsafe.models;

public class App {
    private String appName;
    private String packageName;
    private boolean blocked;

    public App() {}

    public App(String appName, String packageName, boolean blocked) {
        this.appName = appName;
        this.packageName = packageName;
        this.blocked = blocked;
    }

    public String getAppName() { return appName; }
    public String getPackageName() { return packageName; }
    public boolean isBlocked() { return blocked; }
}
