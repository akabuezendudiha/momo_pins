package com.mguardsolutions.momo_pins;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class SimUtil {
    public static List<SimInfo> getSIMInfo(Context context) {
        List<SimInfo> simInfoList = new ArrayList<>();
        try {
            Uri URI_TELEPHONY = Uri.parse("content://telephony/siminfo/");
            Cursor c = context.getContentResolver().query(URI_TELEPHONY, null, null, null, null);
            if (c.moveToFirst()) {
                do {
                    int id = c.getInt(c.getColumnIndex("_id"));
                    int slot = c.getInt(c.getColumnIndex("slot"));
                    String display_name = c.getString(c.getColumnIndex("display_name"));
                    SimInfo simInfo = new SimInfo(id, display_name, slot);
                    simInfoList.add(simInfo);
                } while (c.moveToNext());
            }
            c.close();
            Log.w(MainActivity.TAG, "Done with SIM List reading..");
            return simInfoList;
        } catch (Exception e) {
            Log.w(MainActivity.TAG, e.getMessage());
            return simInfoList;
        }
    }
}
