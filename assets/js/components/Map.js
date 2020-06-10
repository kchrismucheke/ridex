import React, { useState, useEffect } from "react";
import { Map, Marker, TileLayer } from "react-leaflet";
import { usePosition } from "../lib/usePosition";

export default ({ user }) => {
  const position = usePosition();

  if (!position) {
    return <div>Awaiting for position...</div>;
  }

  return (
    <div>
      Logged in as {user.type}
      <Map center={position} zoom={15}>
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        />

        <Marker position={position} />
      </Map>
    </div>
  );
};
