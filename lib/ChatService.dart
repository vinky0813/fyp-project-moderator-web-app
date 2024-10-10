import 'package:supabase_flutter/supabase_flutter.dart';

class Chatservice {

  static Future<String?> createGroup(List<String> memberIds) async {
    final response = await Supabase.instance.client
        .from('Groups').insert({}).select();
    final groupId = response[0]['id'];

    for (final memberId in memberIds) {
      await Supabase.instance.client
          .from('Group_Members').insert({
        'group_id': groupId,
        'user_id': memberId,
      });
    }
    return groupId;
  }

  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await Supabase.instance.client
        .from('group_members')
        .select('user_id')
        .eq('group_id', groupId);
    return response;
  }

  static Future<String?> findOneOnOneGroupId(String userId, String ownerId) async {
    final userGroupsResponse = await Supabase.instance.client
        .from('Group_Members')
        .select('group_id')
        .eq('user_id', userId);

    final userGroups = List<String>.from(userGroupsResponse.map((item) => item['group_id']));

    for (final groupId in userGroups) {
      final ownerMembershipResponse = await Supabase.instance.client
          .from('Group_Members')
          .select('user_id')
          .eq('group_id', groupId)
          .eq('user_id', ownerId);

      if (ownerMembershipResponse.isNotEmpty) {
        final groupMembersResponse = await Supabase.instance.client
            .from('Group_Members')
            .select('user_id')
            .eq('group_id', groupId);

        if (groupMembersResponse.length == 2) {
          return groupId;
        }
      }
    }
    return null;
  }
}
