package com.example.news_app_frontend

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

// 🚀 CLASS 1: The Small Widget
class DailyNewsSmallWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, R.layout.widget_small)
        }
    }
}

// 🚀 CLASS 2: The Medium Widget
class DailyNewsMediumWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, R.layout.widget_medium)
        }
    }
}

// 🚀 SHARED LOGIC: Handles data and clicks for BOTH sizes
internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, layoutId: Int) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val titleData = widgetData.getString("news_title", "Discover News") ?: "Discover News"

    val views = RemoteViews(context.packageName, layoutId)
    views.setTextViewText(R.id.widget_title, titleData)

    // The Small widget doesn't have a summary ID, so we only update it if it's the Medium layout!
    if (layoutId == R.layout.widget_medium) {
        val summaryData = widgetData.getString("news_summary", "Tap to play") ?: "Tap to play"
        views.setTextViewText(R.id.widget_summary, summaryData)
    }

    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("newsapp://play"))
    val pendingIntent = PendingIntent.getActivity(
        context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
    appWidgetManager.updateAppWidget(appWidgetId, views)
}