import React, { useState, useEffect } from 'react'
import { Socket, Presence } from 'phoenix'
import { Map, Marker, Popup, TileLayer } from 'react-leaflet'
import Geohash from 'latlon-geohash'

import { usePosition } from '../../hooks'

function RidexMap({ user }) {
    const position = usePosition()

    const [channel, setChannel] = useState()
    const [userChannel, setUserChannel] = useState()
    const [rideRequests, setRideRequests] = useState([])

    const [presences, setPresences] = useState({})

    const getLat = (position) => position ? position.lat : 0
    const getLng = (position) => position ? position.lng : 0

    useEffect(() => {
        const socket = new Socket('/socket', { params: { token: user.token } })
        socket.connect()

        if (!position)
            return

        const phxChannel = socket.channel(`cell:${geohashFromPosition(position)}`, { position })
        phxChannel
            .join()
            .receive('ok', response => {
                console.log('Joined into channel!')
                setChannel(phxChannel)
            })

        const phxUserChannel = socket.channel('user:' + user.id)
        phxUserChannel
            .join()
            .receive('ok', response => {
                console.log('Joined user channel!')
                setUserChannel(phxUserChannel)
            })

        phxChannel.on('ride:requested', rideRequest => {
            setRideRequests([...rideRequests, rideRequest])
        })

        phxChannel.on('presence_diff', presenceDiff => {
            const syncPresences = Presence.syncDiff(presences, presenceDiff)
            setPresences(syncPresences)
        })

        phxChannel.on('presence_state', state => {
            const syncedPresences = Presence.syncState(presences, state)
            setPresences(syncedPresences)
        })

        phxUserChannel.on('ride:created', ride =>
            console.log('A ride has been created!')
        )

        return () => {
            phxChannel.leave()
            phxUserChannel.leave()
        }
    }, [geohashFromPosition(position)])

    useEffect(() => {
        if (channel) {
            channel.push('update_position', position)
        }
    }, [
        getLat(position),
        getLng(position)
    ])

    const positionsFromPresences = Presence.list(presences)
        .filter(presence => !!presence.metas)
        .map(presence => presence.metas[0])

    function geohashFromPosition(position) {
        return position ? Geohash.encode(position.lat, position.lng, 5) : ''
    }

    function requestRide() {
        channel.push("ride:request", { position })
    }

    const acceptRideRequest = (requestId) => (
        channel.push('ride:request_accepted', { request_id: requestId })
    )

    if (!position) {
        return <div>Awaiting position...</div>
    }

    if (!channel) {
        return <div>Connecting to channel...</div>
    }

    return (
        <div>
            <p>Logged in as {user.type}</p>

            {user.type === 'rider' && (
                <div>
                    <button onClick={requestRide}>Request a ride</button>
                </div>
            )}

            <Map center={position} zoom={15}>
                <TileLayer
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
                />

                {positionsFromPresences.map(({ lat, lng, phx_ref }) => (
                    <Marker key={phx_ref} position={{ lat, lng }} />
                ))}

                <Marker position={position} />

                {rideRequests.map(
                    ({ request_id, position }) => (
                        <Marker key={request_id} position={position}>
                            <Popup>
                                New ride request!
                <button onClick={() => acceptRideRequest(request_id)}>Accept!</button>
                            </Popup>
                        </Marker>
                    )
                )}
            </Map>
        </div>
    )
}

export default RidexMap