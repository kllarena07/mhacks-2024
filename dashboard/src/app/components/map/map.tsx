// "use client";

// import React, { useEffect, useRef } from "react";
// import { Loader } from "@googlemaps/js-api-loader";

// type MapProps = {
//   latitude: number;
//   longitude: number;
// };

// const GoogleMap = ({ latitude, longitude }: MapProps) => {
//   const mapRef = useRef(null);

//   useEffect(() => {
//     const initMap = async () => {
//       const loader = new Loader({
//         apiKey: process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY ?? "",
//         version: "weekly",
//       });

//       const { Map } = await loader.importLibrary("maps");

//       const mapOptions = {
//         center: { lat: latitude, lng: longitude },
//         zoom: 14,
//       };

//       const map = new Map(mapRef.current, mapOptions);

//       // new google.maps.Marker({
//       //   position: { lat: latitude, lng: longitude },
//       //   map: map,
//       // });
//     };

//     initMap();
//   }, [latitude, longitude]);

//   return <div ref={mapRef} className="w-full h-[400px]" />;
// };

// export default GoogleMap;
