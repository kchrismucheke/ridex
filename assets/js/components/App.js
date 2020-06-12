import React, { useState } from 'react'

import Login from './Login'
import Map from './Map'

function App() {
  const [user, setUser] = useState()

  const handleLogin = user => setUser(user)

  if (user) {
    return <Map user={user} />
  }

  return (
    <Login updateUser={handleLogin} />
  )
}

export default App