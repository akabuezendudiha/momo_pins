package com.mguardsolutions.momo_pins;

public class SimInfo {
    private final int _id;
    private final String _displayName;
    private final int _slot;

    public SimInfo(int id, String display_name, int slot) {
        this._id = id;
        this._displayName = display_name;
        this._slot = slot;
    }

    public int getId() {
        return _id;
    }

    public String getDisplayName() {
        return _displayName;
    }

    public int getSlot() {
        return _slot;
    }
}

