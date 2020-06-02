# Ridex

Real-time is everywhere now. It doesn’t matter which kind of application you want to build — a chat, a shared documents service like Google Docs, a social mobile app with push notifications, a live game, or a live news feed, real-time features are more and more needed in modern applications.

Elixir/OTP is a really good platform whenever you want to build backend systems with real-time features, thanks to the Erlang VM foundations. A famous example of applications using such real-time features are ride-sharing applications like Uber or Lyft. A driver checks in on his phone, and riders can request for a ride, before being — hopefully — matched with the closest driver, everything happening in real-time, sometimes in a matter of seconds.

Ridex is a simple prototype for a ride sharing application with Elixir and the Phoenix framework, using some of its real-time communication features like Channels and Presence. For the sake of simplicity, it's a basic web app, allowing users to check in and share their current location, and riders to request for a ride. The web app will contain a map with real-time positions of drivers operating in the area.

## The Domain model

  This application is going to have users that can be either Drivers or Riders. For the sake of simplicity, I have used a common database schema, and assume that a user can be either a Driver or a Rider, but not both.

  A Rider checks in with his phone number, and, assuming he shared his location with our app, is able to see Drivers that are currently in the same area.

  The same Rider can then create a Ride request, containing his current location, to search for an available driver. At that point, the information is broadcasted to all Drivers in the same area. The first Driver to accept the request will initiate a Ride, then pickup the Rider at the requested location.