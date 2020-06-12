import React, { useState } from 'react'

function Login({ updateUser }) {
    const [phone, setPhone] = useState('')

    const handleChange = event => (
        setPhone(event.target.value)
    )

    const handleSubmit = type => () => {
        fetch('/api/authenticate', {
            method: 'POST',
            body: JSON.stringify({ phone, type }),
            headers: {
                'Content-Type': 'application/json'
            },
        })
            .then(res => res.json())
            .then(data => updateUser(data))
    }

    return (
        <div>
            <p>Welcome to Ridex! Please check in using your phone number.</p>
            <input type="text" name="phone" id="phone" value={phone} onChange={handleChange} />

            <button onClick={handleSubmit('driver')}>Login as Driver</button>
            <button onClick={handleSubmit('rider')}>Login as Rider</button>
        </div>
    )
}

export default Login