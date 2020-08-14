package dev.flutterbr.opentok_flutter

import kotlinx.serialization.Serializable

@Serializable
data class SubscriberSettings(
        var name: String?,
        var audioTrack: Boolean?,
        var videoTrack: Boolean?,
        var audioBitrate: Int?,
        var cameraResolution: String?,
        var cameraFrameRate: String?,
        var styleVideoScale: String?)
