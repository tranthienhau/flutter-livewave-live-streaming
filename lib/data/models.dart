enum StreamCategory { music, gaming, cooking, fitness, talk, travel, art }

extension StreamCategoryLabel on StreamCategory {
  String get label => switch (this) {
    StreamCategory.music => 'Music',
    StreamCategory.gaming => 'Gaming',
    StreamCategory.cooking => 'Cooking',
    StreamCategory.fitness => 'Fitness',
    StreamCategory.talk => 'Talk',
    StreamCategory.travel => 'Travel',
    StreamCategory.art => 'Art',
  };
}

class Creator {
  const Creator({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatar,
    required this.category,
    required this.followers,
    this.bio = '',
    this.cover,
    this.streams = 0,
    this.rating = 0,
  });

  final String id;
  final String name;
  final String handle;
  final String avatar;
  final StreamCategory category;
  final int followers;
  final String bio;
  final String? cover;
  final int streams;
  final double rating;
}

class LiveStream {
  const LiveStream({
    required this.id,
    required this.title,
    required this.creator,
    required this.thumbnail,
    required this.viewers,
    required this.category,
  });

  final String id;
  final String title;
  final Creator creator;
  final String thumbnail;
  final int viewers;
  final StreamCategory category;
}

class Replay {
  const Replay({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.ago,
  });

  final String title;
  final String thumbnail;
  final String duration;
  final String views;
  final String ago;
}

class ScheduleSlot {
  const ScheduleSlot(this.when, this.title);
  final String when;
  final String title;
}

enum CommentKind { chat, gift, system }

class LiveComment {
  const LiveComment({
    required this.author,
    required this.text,
    this.avatar,
    this.kind = CommentKind.chat,
    this.pinned = false,
  });

  final String author;
  final String text;
  final String? avatar;
  final CommentKind kind;
  final bool pinned;

  LiveComment copyWith({bool? pinned}) => LiveComment(
    author: author,
    text: text,
    avatar: avatar,
    kind: kind,
    pinned: pinned ?? this.pinned,
  );
}

class Gift {
  const Gift(this.id, this.name, this.price, this.glyph);
  final String id;
  final String name;
  final int price;
  final String glyph;
}

class CoinPack {
  const CoinPack(this.coins, this.price, {this.popular = false});
  final int coins;
  final String price;
  final bool popular;
}

class WalletTxn {
  const WalletTxn(this.title, this.when, this.amount, this.kind);
  final String title;
  final String when;
  final int amount;
  final String kind; // gift_out, gift_in, topup
}

class Supporter {
  const Supporter(this.name, this.avatar, this.coins);
  final String name;
  final String? avatar;
  final int coins;
}
