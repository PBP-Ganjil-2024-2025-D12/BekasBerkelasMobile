class Question {
   String model;
   String pk;
   QuestionFields fields; 

   Question({
       required this.model,
       required this.pk,
       required this.fields,
   });

   factory Question.fromJson(Map<String, dynamic> json) {
       var fieldsData = json["fields"] as Map<String, dynamic>;
       return Question(
           model: json["model"] ?? "forum.question",
           pk: json["pk"].toString(),
           fields: QuestionFields.fromJson(fieldsData),  
       );
   }

   Map<String, dynamic> toJson() => {
       "model": model,
       "pk": pk,
       "fields": fields.toJson(),
   };
}

class QuestionFields { 
   int user;
   String? car;
   String title;
   String content;
   String category;
   String createdAt;
   String updatedAt;
   String username;  
   int replyCount;  

   QuestionFields({  
       required this.user,
       this.car,
       required this.title,
       required this.content,
       required this.category,
       required this.createdAt,
       required this.updatedAt,
       required this.username,
       required this.replyCount,
   });

   factory QuestionFields.fromJson(Map<String, dynamic> json) {
  
  return QuestionFields(  
    user: json["user"],
    car: json["car"]?.toString(),
    title: json["title"],
    content: json["content"],
    category: json["category"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    username: json["username"] ?? "",
    replyCount: json["reply_count"] ?? 0,
  );
}

   Map<String, dynamic> toJson() => {
       "user": user,
       "car": car,
       "title": title,
       "content": content,
       "category": category,
       "created_at": createdAt,
       "updated_at": updatedAt,
       "username": username,
       "reply_count": replyCount,
   };
}