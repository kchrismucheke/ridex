import React, { useState } from "react";
import Login from "./Login";
import Map from "./Map";

export default () => {
  const [user, setUser] = useState();

  const handleLogin = (user) => setUser(user);

  return user ? <Map user={user} /> : <Login onLogin={handleLogin} />;
};
