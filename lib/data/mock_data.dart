import 'models.dart';

const _img = 'assets/images';

class Img {
  static const maya = '$_img/avatar-maya.jpg';
  static const lena = '$_img/avatar-lena.jpg';
  static const marco = '$_img/avatar-marco.jpg';
  static const aiko = '$_img/avatar-aiko.jpg';
  static const sam = '$_img/avatar-sam.jpg';
  static const kenji = '$_img/avatar-kenji.jpg';
  static const sofia = '$_img/avatar-sofia.jpg';
  static const welcome = '$_img/hero-welcome.jpg';
  static const djKairo = '$_img/stream-dj-kairo.jpg';
  static const pasta = '$_img/stream-pasta.jpg';
  static const acoustic = '$_img/stream-acoustic.jpg';
  static const hiit = '$_img/stream-hiit.jpg';
  static const lisbon = '$_img/stream-lisbon.jpg';
  static const painter = '$_img/stream-painter.jpg';
  static const chefPlating = '$_img/stream-chef-plating.jpg';
  static const saxophone = '$_img/stream-saxophone.jpg';
  static const emptyDesk = '$_img/empty-studio-desk.jpg';
  static const lenaCover = '$_img/cover-lena-studio.jpg';
  static const replayPiano = '$_img/replay-piano.jpg';
  static const replayPainting = '$_img/replay-painting.jpg';
  static const replayCity = '$_img/replay-city-walk.jpg';
  static const liveLena = '$_img/live-lena.jpg';
  static const liveHost = '$_img/live-host-coffee.jpg';
  static const hostPreview = '$_img/host-preview.jpg';
  static const appIcon = '$_img/app-icon.png';
}

class Mock {
  static const me = Creator(
    id: 'maya',
    name: 'Maya Chen',
    handle: '@mayalive',
    avatar: Img.maya,
    category: StreamCategory.talk,
    followers: 3210,
    streams: 46,
  );

  static const lena = Creator(
    id: 'lena',
    name: 'Lena Park',
    handle: '@lenaplays',
    avatar: Img.lena,
    category: StreamCategory.music,
    followers: 48200,
    bio: 'Acoustic covers every night 8pm',
    cover: Img.lenaCover,
    streams: 312,
    rating: 4.9,
  );
  static const djKairo = Creator(
    id: 'kairo',
    name: 'DJ Kairo',
    handle: '@djkairo',
    avatar: Img.djKairo,
    category: StreamCategory.music,
    followers: 128000,
  );
  static const marco = Creator(
    id: 'marco',
    name: 'Marco Ruiz',
    handle: '@marcocooks',
    avatar: Img.marco,
    category: StreamCategory.cooking,
    followers: 21400,
  );
  static const aiko = Creator(
    id: 'aiko',
    name: 'Aiko Tan',
    handle: '@aikodraws',
    avatar: Img.aiko,
    category: StreamCategory.art,
    followers: 18300,
  );
  static const sam = Creator(
    id: 'sam',
    name: 'Sam Okafor',
    handle: '@samlifts',
    avatar: Img.sam,
    category: StreamCategory.fitness,
    followers: 95100,
  );

  static const following = [lena, marco, aiko, sam];

  static const featured = LiveStream(
    id: 'kairo-house',
    title: 'Friday Night House Set',
    creator: djKairo,
    thumbnail: Img.djKairo,
    viewers: 12400,
    category: StreamCategory.music,
  );

  static const liveNow = [
    LiveStream(
      id: 'pasta',
      title: 'Handmade Pasta Night',
      creator: marco,
      thumbnail: Img.pasta,
      viewers: 842,
      category: StreamCategory.cooking,
    ),
    LiveStream(
      id: 'acoustic',
      title: 'Acoustic Requests',
      creator: lena,
      thumbnail: Img.acoustic,
      viewers: 2481,
      category: StreamCategory.music,
    ),
    LiveStream(
      id: 'hiit',
      title: 'Full Body Kettlebell HIIT',
      creator: sam,
      thumbnail: Img.hiit,
      viewers: 1100,
      category: StreamCategory.fitness,
    ),
    LiveStream(
      id: 'lisbon',
      title: 'Lisbon Sunset Walk',
      creator: aiko,
      thumbnail: Img.lisbon,
      viewers: 530,
      category: StreamCategory.travel,
    ),
  ];

  static const trending = [
    LiveStream(
      id: 'painter',
      title: 'Oil Painting Live',
      creator: aiko,
      thumbnail: Img.painter,
      viewers: 1900,
      category: StreamCategory.art,
    ),
    LiveStream(
      id: 'plating',
      title: 'Chef Table Plating',
      creator: marco,
      thumbnail: Img.chefPlating,
      viewers: 1340,
      category: StreamCategory.cooking,
    ),
    LiveStream(
      id: 'sax',
      title: 'Midnight Sax Session',
      creator: djKairo,
      thumbnail: Img.saxophone,
      viewers: 760,
      category: StreamCategory.music,
    ),
  ];

  static const topCategories = [
    (StreamCategory.music, Img.acoustic, '1.2K live'),
    (StreamCategory.cooking, Img.pasta, '640 live'),
    (StreamCategory.fitness, Img.hiit, '410 live'),
    (StreamCategory.travel, Img.lisbon, '280 live'),
  ];

  static const lenaSchedule = [
    ScheduleSlot('Mon 8:00 PM', 'Acoustic requests'),
    ScheduleSlot('Wed 8:00 PM', 'Songwriting session'),
  ];

  static const lenaReplays = [
    Replay(
      title: 'Sunday Acoustic Jam',
      thumbnail: Img.acoustic,
      duration: '1:24:10',
      views: '12K views',
      ago: '2d ago',
    ),
    Replay(
      title: 'Piano and Vocals',
      thumbnail: Img.replayPiano,
      duration: '58:32',
      views: '8.9K views',
      ago: '5d ago',
    ),
  ];

  static const myReplays = [
    Replay(
      title: 'Pasta Night with Chat',
      thumbnail: Img.pasta,
      duration: '52:10',
      views: '8.4K views',
      ago: '2d ago',
    ),
    Replay(
      title: 'Morning Coffee and Q&A',
      thumbnail: Img.hostPreview,
      duration: '45:20',
      views: '5.1K views',
      ago: '4d ago',
    ),
    Replay(
      title: 'Painting in the Studio',
      thumbnail: Img.replayPainting,
      duration: '1:12:04',
      views: '9.2K views',
      ago: '6d ago',
    ),
    Replay(
      title: 'Late Night City Stroll',
      thumbnail: Img.replayCity,
      duration: '38:15',
      views: '6.7K views',
      ago: '1w ago',
    ),
  ];

  static const gifts = [
    Gift('rose', 'Rose', 1, 'rose'),
    Gift('heart', 'Heart', 5, 'heart'),
    Gift('coffee', 'Coffee', 10, 'coffee'),
    Gift('star', 'Star', 25, 'star'),
    Gift('mic', 'Mic', 50, 'mic'),
    Gift('rocket', 'Rocket', 100, 'rocket'),
    Gift('crown', 'Crown', 500, 'crown'),
    Gift('wave', 'Wave', 1000, 'wave'),
  ];

  static const coinPacks = [
    CoinPack(100, r'$0.99'),
    CoinPack(500, r'$4.99'),
    CoinPack(1200, r'$9.99', popular: true),
    CoinPack(2500, r'$19.99'),
    CoinPack(6500, r'$49.99'),
    CoinPack(14000, r'$99.99'),
  ];

  static const transactions = [
    WalletTxn('Sent Rocket to Lena Park', 'Today, 2:15 PM', -100, 'gift_out'),
    WalletTxn(
      'Received Crown from Sofia',
      'Yesterday, 8:40 PM',
      500,
      'gift_in',
    ),
    WalletTxn('Top up', 'Oct 12, 10:14 AM', 1200, 'topup'),
  ];

  /// Scripted viewer chat for the watch screen; the room cycles through it.
  static const viewerChat = [
    LiveComment(author: 'Ava', text: 'play Yellow please!'),
    LiveComment(author: 'Kenji', text: 'hello from Tokyo', avatar: Img.kenji),
    LiveComment(
      author: 'Sofia',
      text: 'your voice is unreal',
      avatar: Img.sofia,
    ),
    LiveComment(author: 'Marco', text: 'first time here', avatar: Img.marco),
    LiveComment(
      author: 'Marco',
      text: 'sent a Rose x5',
      avatar: Img.marco,
      kind: CommentKind.gift,
    ),
    LiveComment(author: 'Aiko', text: 'love this song', avatar: Img.aiko),
    LiveComment(
      author: 'Sam',
      text: 'this is my study playlist now',
      avatar: Img.sam,
    ),
    LiveComment(author: 'Kenji', text: 'encore!', avatar: Img.kenji),
  ];

  static const hostChat = [
    LiveComment(
      author: 'Ava',
      text: 'what coffee beans do you use?',
      pinned: true,
    ),
    LiveComment(author: 'Kenji', text: 'good morning!', avatar: Img.kenji),
    LiveComment(author: 'Marco', text: 'from Madrid', avatar: Img.marco),
    LiveComment(author: 'Aiko', text: 'love the setup', avatar: Img.aiko),
    LiveComment(
      author: 'Sam',
      text: 'audio sounds crisp today',
      avatar: Img.sam,
    ),
    LiveComment(
      author: 'Sofia',
      text: 'how long have you been streaming?',
      avatar: Img.sofia,
    ),
  ];

  static const supporters = [
    Supporter('Sofia', Img.sofia, 1500),
    Supporter('Marco', Img.marco, 900),
    Supporter('Ava', null, 600),
  ];
}
