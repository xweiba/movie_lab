import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:movielab/.api.dart';
import 'package:movielab/constants/app.dart';
import 'package:movielab/constants/types.dart';
import 'package:movielab/models/item_models/actor_models/full_actor_model.dart';
import 'package:movielab/models/item_models/show_models/external_sites_model.dart';
import 'package:movielab/models/item_models/show_models/full_show_model.dart';
import 'package:movielab/models/item_models/show_models/show_preview_model.dart';
import 'package:movielab/modules/api/key_getter.dart';
import 'package:movielab/modules/cache/cacheholder.dart';
import 'package:movielab/pages/main/home/home_data_controller.dart';
import 'package:movielab/pages/main/search/search_bar/search_bar_controller.dart';
class ImageUtils {
  static const String baseUrl = "https://image.tmdb.org/t/p/";

  // 添加前缀，默认使用 original 尺寸
  static String addPrefix(String path, {String size = "w500"}) {
    if (path.isEmpty) {
      return ""; // 如果路径为空，返回空字符串
    }
    return "$baseUrl$size$path";
  }
}
class APIRequester {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  // API keys to access the TMDb API:
  static int activeApiKey = Random().nextInt(apiKeys.length);
  static List<int> notWorkingApiKeys = [];

  // Get recently trending movies from the TMDb API
  Future<RequestResult> getTrendingMovies() async {
    final response = await getUrl(endpoint: "trending/movie/week");
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      List<ShowPreview> trendingMovies = [];
      for (int i = 0; i < json['results'].length; i++) {
        if (!unavailableIDs.contains(json['results'][i]["id"])) {
          trendingMovies.add(ShowPreview.fromJson(json['results'][i]));
        }
      }
      Get.find<HomeDataController>()
          .updateTrendingMovies(trendingMovies: trendingMovies);
      return RequestResult.SUCCESS;
    } else {
      return RequestResult.FAILURE_SERVER_PROBLEM;
    }
  }

  // Get recently trending TV shows from the TMDb API
  Future<RequestResult> getTrendingTVShows() async {
    final response = await getUrl(endpoint: "trending/tv/week");

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["results"];

      List<ShowPreview> trendingShows = [];
      for (int i = 0; i < json.length; i++) {
        if (!unavailableIDs.contains(json[i]["id"])) {
          trendingShows.add(ShowPreview.fromJson(json[i]));
        }
      }
      Get.find<HomeDataController>()
          .updateTrendingShows(trendingShows: trendingShows);
      return RequestResult.SUCCESS;
    } else {
      return RequestResult.FAILURE_SERVER_PROBLEM;
    }
  }

  // Get movies which are currently playing in the theaters from the TMDb API
  Future<RequestResult> getInTheaters() async {
    final response = await getUrl(endpoint: "movie/now_playing");

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["results"];

      List<ShowPreview> inTheaters = [];
      for (int i = 0; i < json.length; i++) {
        if (!unavailableIDs.contains(json[i]["id"])) {
          inTheaters.add(ShowPreview.fromJson(json[i]));
        }
      }
      Get.find<HomeDataController>().updateInTheaters(inTheaters: inTheaters);
      return RequestResult.SUCCESS;
    } else {
      return RequestResult.FAILURE_SERVER_PROBLEM;
    }
  }

  // Get IMDB 250 most trending movies or TV shows from the IMDB API
  Future<bool> getIMDBlists({required ImdbList listName}) async {
    HomeDataController homeDataController = Get.find<HomeDataController>();
    http.Response response;
    switch (listName) {
      case ImdbList.TOP_250_MOVIES:
        response = await getUrl(endpoint: "movie/top_rated");
        break;
      case ImdbList.TOP_250_TVS:
        response = await getUrl(endpoint: "tv/top_rated");
        break;
      case ImdbList.BoxOffice:
        response = await getUrl(endpoint: "movie/now_playing");
        break;
      case ImdbList.AllTimeBoxOffice:
        response = await getUrl(endpoint: "movie/popular");
        break;
    }
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["results"];
      List<ShowPreview> resultList = [];
      for (int i = 0; i < json.length; i++) {
        resultList.add(ShowPreview.fromJson(json[i]));
      }
      switch (listName) {
        case ImdbList.TOP_250_MOVIES:
          homeDataController.updateTopRatedMovies(topRatedMovies: resultList);
          break;
        case ImdbList.TOP_250_TVS:
          homeDataController.updateTopRatedShows(topRatedShows: resultList);
          break;
        case ImdbList.BoxOffice:
          homeDataController.updateBoxOffice(boxOffice: resultList);
          break;
        case ImdbList.AllTimeBoxOffice:
          homeDataController.updateAllTimeBoxOffice(
              allTimeBoxOffice: resultList);
          break;
      }
      return true;
    } else {
      return false;
    }
  }

  // Get a company's movies from the TMDb API
  Future<Map?> getCompany({required String id}) async {
    final response = await getUrl(endpoint: "company/$id/movies");
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["results"];
      List<ShowPreview> companyMovies = [];
      for (int i = 0; i < json.length; i++) {
        companyMovies.add(ShowPreview.fromJson(json[i]));
      }
      return {
        "name": jsonDecode(response.body)["name"],
        "movies": companyMovies,
      };
    } else {
      return null;
    }
  }

  // Get results of a search query from the TMDb API
  Future<bool> search({expression, required final String searchType}) async {
    expression ??= Get.find<SearchBarController>().fieldText;
    final response = await getUrl(
      endpoint: "search/$searchType",
      queryParameters: {"query": expression},
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["results"];
      List<ShowPreview> result = [];
      for (int i = 0; i < json.length; i++) {
        result.add(ShowPreview.fromJson(json[i]));
      }
      if (searchType == "movie") {
        Get.find<SearchBarController>().updateResult(movieResult: result);
      } else if (searchType == "tv") {
        Get.find<SearchBarController>().updateResult(seriesResult: result);
      } else if (searchType == "person") {
        Get.find<SearchBarController>().updateResult(peopleResult: result);
      }
      return true;
    } else {
      return false;
    }
  }

  // Get full details of a show from the TMDb API
  Future<FullShow?> getShow({required String id}) async {
    final response = await getUrl(
      endpoint: "movie/$id", // 默认使用电影类型
      queryParameters: {"append_to_response": "images,videos,credits"},
    );
    if (response.statusCode == 200) {
      var showJson = jsonDecode(response.body);
      try {
        FullShow show = FullShow.fromJson(showJson);
        return show;
      } catch (e, stacer) {
        print(stacer);
      }
    } else {
      return null;
    }
  }

  // Get episodes info of a season of a show from the TMDb API
  Future<FullShow?> getShowEpisodes(
      {required dynamic show, required int season}) async {
    final cacheHolder = CacheHolder();
    final response = await getUrl(
      endpoint: "tv/${show.id}/season/$season",
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["episodes"];
      List<ShowPreview> seasonEpisodes = [];
      for (int i = 0; i < json.length; i++) {
        seasonEpisodes.add(ShowPreview.fromJson(json[i]));
      }
      show.seasons[season - 1] = seasonEpisodes;
      cacheHolder.saveShowInfoInCache(show: show);
      if (kDebugMode) {
        print("Season $season Episodes has been added");
      }
      return show;
    } else {
      return null;
    }
  }

  // Get full details of an actor from the TMDb API
  Future<FullActor?> getActor({required String id}) async {
    final response = await getUrl(
      endpoint: "person/$id",
      queryParameters: {"append_to_response": "combined_credits"},
    );

    if (response.statusCode == 200) {
      var actorJson = jsonDecode(response.body);
      FullActor actor = FullActor.fromJson(actorJson);
      return actor;
    } else {
      return null;
    }
  }

  // Get external sites of a show from the TMDb API
  Future<ExternalSites?> getExternalSites({required String id}) async {
    final response = await getUrl(
      endpoint: "movie/$id/external_ids", // 默认使用电影类型
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      late ExternalSites externalSites;
      externalSites = ExternalSites.fromJson(json);
      return externalSites;
    } else {
      return null;
    }
  }

  // Get popular movies/series of a specific genre
  Future<List<ShowPreview>?> getGenreItems({required String genre}) async {
    final response = await getUrl(
      endpoint: "discover/movie",
      queryParameters: {"with_genres": genre},
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)["results"];
      List<ShowPreview> result = [];
      for (int i = 0; i < json.length; i++) {
        result.add(ShowPreview.fromJson(json[i]));
      }
      return result;
    } else {
      return null;
    }
  }

  Future getUrl({
    required String endpoint,
    Map<String, String>? queryParameters,
  }) async {
    String url;
    if (apiKeys.isEmpty ||
        (apiKeys.length == 1 && apiKeys[0] == "XXXXXXXXXX")) {
      var response;
      await key_getter().then((result) async {
        if (result == RequestResult.FAILURE) {
          if (kDebugMode) {
            print(
                "You haven't add any api key to the app, so it won't work!\nFor more information check out the documentation at https://github.com/ErfanRht/MovieLab#getting-started");
          }
          response = null;
        } else {
          await getUrl(endpoint: endpoint, queryParameters: queryParameters)
              .then((responseBody) {
            response = responseBody;
          });
          return response;
        }
        return response;
      });
      return response;
    } else if (apiKeys.isNotEmpty) {
      final Map<String, String> params = {
        "api_key": apiKeys[activeApiKey],
        ...?queryParameters,
      };
      url = "$tmdbBaseUrl/$endpoint?${Uri(queryParameters: params).query}";
      if (kDebugMode) {
        print("Requesting $url");
      }
      var response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) {
        // Here we handle the TMDb API limit error
        // If the API key is invalid, change it to the next one
        if (kDebugMode) {
          if (jsonDecode(response.body)['status_code'] == 7) {
            print("${apiKeys[activeApiKey]} is Invalid");
            notWorkingApiKeys.add(activeApiKey);
            // $activeApiKey has been added to notWorkingApiKeys
          } else {
            print("Server error: ${jsonDecode(response.body)['status_message']}");
            notWorkingApiKeys.add(activeApiKey);
            // $activeApiKey has been added to notWorkingApiKeys
          }
        }

        while (true) {
          if (notWorkingApiKeys.length < apiKeys.length) {
            activeApiKey = Random().nextInt(apiKeys.length);
            if (!notWorkingApiKeys.contains(activeApiKey)) {
              if (kDebugMode) {
                print("activeApiKey has been changed to: $activeApiKey");
              }
              await getUrl(endpoint: endpoint, queryParameters: queryParameters)
                  .then((value) {
                response = value;
              });
              break;
            }
          } else {
            if (kDebugMode) {
              print(
                  "There is no working api keys available anymore! It's done.");
            }
            break;
          }
        }
      }
      return response;
    }
  }
}
