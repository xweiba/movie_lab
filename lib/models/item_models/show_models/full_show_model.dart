import 'package:movielab/models/item_models/actor_models/actor_preview_model.dart';
import 'package:movielab/modules/api/api_requester.dart';
import 'package:movielab/modules/tools/image_quality_increaser.dart';
import 'show_preview_model.dart';

// Movie or TV show all detail model class
class FullShow {
  final String id;
  final String title;
  final String type;
  final String image;
  final List images;
  final List posters;
  final String year;
  final String genres;
  final String releaseDate;
  final String yearEnd;
  final String runTime;
  final String plot;
  final String awards;
  final String directors;
  final String writers;
  final String creators;
  final List<dynamic> seasons;
  final List<ActorPreview> actorList;
  final String countries;
  final String companies;
  final String languages;
  final String imDbRating;
  final String imDbVotes;
  final String contentRating;
  final Map<String, dynamic> otherRatings;
  final String budget;
  final String openingWeekendUSA;
  final String grossUSA;
  final String cumulativeWorldwideGross;
  final List<ShowPreview> similars;
  final String tagline;
  final String keywords;
  final String weekend;
  final String gross;
  final String weeks;
  final String worldwideLifetimeGross;
  final String domesticLifetimeGross;
  final String domestic;
  final String foreignLifetimeGross;
  final String foreign;

  const FullShow({
    required this.id,
    required this.title,
    required this.type,
    required this.image,
    required this.images,
    required this.posters,
    required this.year,
    required this.genres,
    required this.releaseDate,
    required this.yearEnd,
    required this.runTime,
    required this.plot,
    required this.awards,
    required this.directors,
    required this.writers,
    required this.creators,
    required this.seasons,
    required this.actorList,
    required this.countries,
    required this.languages,
    required this.companies,
    required this.imDbRating,
    required this.imDbVotes,
    required this.contentRating,
    required this.otherRatings,
    required this.budget,
    required this.openingWeekendUSA,
    required this.grossUSA,
    required this.cumulativeWorldwideGross,
    required this.similars,
    required this.tagline,
    required this.keywords,
    required this.weekend,
    required this.gross,
    required this.weeks,
    required this.worldwideLifetimeGross,
    required this.domesticLifetimeGross,
    required this.domestic,
    required this.foreignLifetimeGross,
    required this.foreign,
  });

  factory FullShow.fromJson(Map<String, dynamic> json) {
    return FullShow(
      id: json['id']?.toString() ?? "", // TMDb 返回的 id 是整数
      title: json['title'] ?? "",
      type: json['media_type'] ?? "", // TMDb 使用 media_type 来区分类型
      image: ImageUtils.addPrefix(json['poster_path']), // 使用 ImageUtils.addPrefix 添加前缀
      images: json['images'] != null
          ? (json['images']['backdrops'] as List<dynamic>?)
          ?.map((image) => ImageUtils.addPrefix(image['file_path']))
          .toList() ?? []
          : [],
      posters: json['images']?['posters'] != null
          ? (json['images']['posters'] as List<dynamic>?)
          ?.map((poster) => PosterData.fromJson({
        'file_path': ImageUtils.addPrefix(poster['file_path']),
        'other_fields': poster, // 保留其他字段
      }))
          .toList() ?? <PosterData>[]
          : <PosterData>[],
      year: json['release_date']?.split('-')[0] ?? "", // 从 release_date 中提取年份
      genres: (json['genres'] as List<dynamic>?)?.map((genre) => genre['name']).join(", ") ?? "", // 将 genres 列表转换为逗号分隔的字符串
      releaseDate: json['release_date'] ?? "",
      yearEnd: json['last_air_date']?.split('-')[0] ?? "", // 对于电视剧，使用 last_air_date 提取结束年份
      runTime: json['runtime']?.toString() ?? "", // TMDb 使用 runtime 表示电影时长
      plot: json['overview'] ?? "", // TMDb 使用 overview 表示剧情简介
      awards: "", // TMDb API 不提供奖项信息
      directors: (json['credits']?['crew'] as List<dynamic>?)
          ?.where((crew) => crew['job'] == 'Director')
          .map((crew) => crew['name'])
          .join(", ") ?? "", // 从 crew 中筛选出导演
      writers: (json['credits']?['crew'] as List<dynamic>?)
          ?.where((crew) => crew['job'] == 'Writer')
          .map((crew) => crew['name'])
          .join(", ") ?? "", // 从 crew 中筛选出编剧
      creators: (json['created_by'] as List<dynamic>?)
          ?.map((creator) => creator['name'])
          .join(", ") ?? "", // 对于电视剧，使用 created_by 表示创作者
      seasons: json['seasons'] != null
          ? List<dynamic>.generate(json['seasons'].length, (index) => [])
          : [],
      actorList: json['credits']?['cast'] != null
          ? List<ActorPreview>.generate(
        json['credits']['cast'].length,
            (index) {
          final actor = json['credits']['cast'][index];
          return ActorPreview.fromJson({
            'id': actor['id']?.toString() ?? "", // 确保 id 是 String 类型
            'name': actor['name'] ?? "", // 处理 name 为 null 的情况
            'profile_path': actor['profile_path'] == null ? "" :ImageUtils.addPrefix(actor['profile_path']), // 处理 profile_path 为 null 的情况
            'character': actor['character'] ?? "", // 处理 character 为 null 的情况
          });
        },
      )
          : [],
      countries: (json['production_countries'] as List<dynamic>?)
          ?.map((country) => country['name'])
          .join(", ") ?? "", // 将 production_countries 转换为逗号分隔的字符串
      languages: (json['spoken_languages'] as List<dynamic>?)
          ?.map((language) => language['name'])
          .join(", ") ?? "", // 将 spoken_languages 转换为逗号分隔的字符串
      companies: (json['production_companies'] as List<dynamic>?)
          ?.map((company) => company['name'])
          .join(", ") ?? "", // 将 production_companies 转换为逗号分隔的字符串
      imDbRating: json['vote_average']?.toString() ?? "0.0", // TMDb 使用 vote_average 表示评分
      imDbVotes: json['vote_count']?.toString() ?? "0", // TMDb 使用 vote_count 表示投票数
      contentRating: json['adult'] == true ? "R" : "PG", // 根据 adult 字段判断内容分级
      otherRatings: {}, // TMDb API 不提供其他评分信息
      budget: json['budget']?.toString() ?? "",
      openingWeekendUSA: "", // TMDb API 不提供开映周末票房信息
      grossUSA: "", // TMDb API 不提供美国总票房信息
      cumulativeWorldwideGross: json['revenue']?.toString() ?? "", // TMDb 使用 revenue 表示全球总票房
      similars: getSimilars(json: json['similar']?['results'] ?? []) ?? [], // TMDb 使用 similar 表示类似作品
      tagline: json['tagline'] ?? "",
      keywords: (json['keywords']?['keywords'] as List<dynamic>?)
          ?.map((keyword) => keyword['name'])
          .join(", ") ?? "", // 将 keywords 转换为逗号分隔的字符串
      weekend: "", // TMDb API 不提供周末票房信息
      gross: "", // TMDb API 不提供总票房信息
      weeks: "", // TMDb API 不提供上映周数信息
      worldwideLifetimeGross: json['revenue']?.toString() ?? "", // TMDb 使用 revenue 表示全球总票房
      domesticLifetimeGross: "", // TMDb API 不提供美国国内总票房信息
      domestic: "", // TMDb API 不提供美国国内票房信息
      foreignLifetimeGross: "", // TMDb API 不提供海外总票房信息
      foreign: "", // TMDb API 不提供海外票房信息
    );
  }
}

// Get similar movies or TV shows to a movie or TV show from the API
List<ShowPreview>? getSimilars({required json}) {
  List<ShowPreview> similars = [];
  for (int i = 0; i < json.length; i++) {
    json[i]["rank"] = i.toString();
    similars.add(ShowPreview.fromJson(json[i]));
  }
  return similars;
}

// An image data model class
class ImageData {
  final String title;
  final String imageUrl;

  const ImageData({
    required this.title,
    required this.imageUrl,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      title: json['title'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
    );
  }

  static List<ImageData>? getImages(Map<String, dynamic>? json) {
    return (json!['items'] as List<dynamic>)
        .map<ImageData>((item) => ImageData.fromJson(item))
        .toList();
  }
}

// An image data model class
class PosterData {
  final String id;
  final String link;

  const PosterData({
    required this.id,
    required this.link,
  });

  factory PosterData.fromJson(Map<String, dynamic> json) {
    return PosterData(
      id: json['id']?.toString() ?? "",
      link: json['link'] ?? "",
    );
  }

  static List<PosterData>? getPosters(Map<String, dynamic> json) {
    return (json['posters'] as List<dynamic>)
        .map<PosterData>((item) => PosterData.fromJson(item))
        .toList();
  }
}
