// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final uuid = const Uuid();

  /// CREATE ROOM
  Future<String> createRoom({
    required String playerId,
    required int maxPlayers,
  }) async {
    String roomId = uuid.v4().substring(0, 6);

    await _firestore.collection("rooms").doc(roomId).set({
      "roomId": roomId,
      "host": playerId,
      "players": [playerId],
      "maxPlayers": maxPlayers,
      "currentTurn": playerId,
      "grid": [],
      "status": "waiting",
      "createdAt": FieldValue.serverTimestamp()
    });

    return roomId;
  }

  /// JOIN ROOM
  Future<void> joinRoom({
    required String roomId,
    required String playerId,
  }) async {
    await _firestore.collection("rooms").doc(roomId).update({
      "players": FieldValue.arrayUnion([playerId])
    });
  }

  /// LISTEN ROOM REALTIME
  Stream<DocumentSnapshot> listenRoom(String roomId) {
    return _firestore.collection("rooms").doc(roomId).snapshots();
  }

  /// UPDATE GRID
  Future<void> updateGame({
    required String roomId,
    required List grid,
    required String nextTurn,
  }) async {
    await _firestore
        .collection("rooms")
        .doc(roomId)
        .update({"grid": grid, "currentTurn": nextTurn});
  }
}
