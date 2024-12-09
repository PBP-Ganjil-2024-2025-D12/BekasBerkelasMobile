// reply.dart 
class Reply {
    String model;
    String pk;
    ReplyFields fields;

    Reply({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        model: "forum.reply",
        pk: json["id"] ?? "",
        fields: ReplyFields(
            question: "",
            user: json["user"] ?? 0,
            content: json["content"] ?? "",
            createdAt: json["created_at"] ?? "",
            updatedAt: json["updated_at"] ?? "",
            username: json["username"] ?? "Unknown",
        ),
    );
}

class ReplyFields {
    String question;
    int user;
    String content;
    String createdAt;
    String updatedAt;
    String username;

    ReplyFields({
        required this.question,
        required this.user,
        required this.content,
        required this.createdAt,
        required this.updatedAt,
        required this.username,
    });
}