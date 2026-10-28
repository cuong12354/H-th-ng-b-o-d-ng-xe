import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store_content_models.dart';

class StoreContentProvider extends ChangeNotifier {
  static const String _keyStoreInfo = 'store_content_info';
  static const String _keyCampaigns = 'store_content_campaigns';
  static const String _keyPackages = 'store_content_packages';
  static const String _keyMilestones = 'store_content_milestones';
  static const String _keyNews = 'store_content_news';
  static const String _keyVouchers = 'store_content_vouchers';

  StoreInfo _storeInfo = StoreInfo.defaultInfo();
  List<CampaignItem> _campaigns = CampaignItem.defaultCampaigns();
  List<PrepaidPackageItem> _packages = PrepaidPackageItem.defaultPackages();
  List<MaintenanceMilestone> _milestones = MaintenanceMilestone.defaultMilestones();
  List<NewsItem> _newsList = NewsItem.defaultNews();
  List<RewardVoucherItem> _vouchers = RewardVoucherItem.defaultVouchers();

  bool _isLoaded = false;

  StoreInfo get storeInfo => _storeInfo;
  List<CampaignItem> get campaigns => _campaigns.where((c) => c.isActive).toList();
  List<CampaignItem> get allCampaigns => _campaigns;
  List<PrepaidPackageItem> get packages => _packages.where((p) => p.isActive).toList();
  List<PrepaidPackageItem> get allPackages => _packages;
  List<MaintenanceMilestone> get milestones => _milestones;
  List<NewsItem> get newsList => _newsList;
  List<RewardVoucherItem> get vouchers => _vouchers;
  bool get isLoaded => _isLoaded;

  StoreContentProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store Info
      final storeStr = prefs.getString(_keyStoreInfo);
      if (storeStr != null && storeStr.isNotEmpty) {
        _storeInfo = StoreInfo.fromJson(jsonDecode(storeStr));
      }

      // Campaigns
      final campStr = prefs.getString(_keyCampaigns);
      if (campStr != null && campStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(campStr);
        _campaigns = list.map((e) => CampaignItem.fromJson(e)).toList();
      }

      // Packages
      final pkgStr = prefs.getString(_keyPackages);
      if (pkgStr != null && pkgStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(pkgStr);
        _packages = list.map((e) => PrepaidPackageItem.fromJson(e)).toList();
      }

      // Milestones
      final mlsStr = prefs.getString(_keyMilestones);
      if (mlsStr != null && mlsStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(mlsStr);
        _milestones = list.map((e) => MaintenanceMilestone.fromJson(e)).toList();
      }

      // News
      final newsStr = prefs.getString(_keyNews);
      if (newsStr != null && newsStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(newsStr);
        _newsList = list.map((e) => NewsItem.fromJson(e)).toList();
      }

      // Vouchers
      final vchStr = prefs.getString(_keyVouchers);
      if (vchStr != null && vchStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(vchStr);
        _vouchers = list.map((e) => RewardVoucherItem.fromJson(e)).toList();
      }

      _isLoaded = true;
      notifyListeners();
    } catch (_) {
      _isLoaded = true;
      notifyListeners();
    }
  }

  // =================== STORE INFO ===================
  Future<void> updateStoreInfo(StoreInfo info) async {
    _storeInfo = info;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreInfo, jsonEncode(info.toJson()));
  }

  // =================== CAMPAIGNS ===================
  Future<void> saveCampaigns() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCampaigns, jsonEncode(_campaigns.map((e) => e.toJson()).toList()));
  }

  Future<void> addCampaign(CampaignItem item) async {
    _campaigns.insert(0, item);
    await saveCampaigns();
  }

  Future<void> updateCampaign(CampaignItem item) async {
    final idx = _campaigns.indexWhere((c) => c.id == item.id);
    if (idx != -1) {
      _campaigns[idx] = item;
      await saveCampaigns();
    }
  }

  Future<void> deleteCampaign(String id) async {
    _campaigns.removeWhere((c) => c.id == id);
    await saveCampaigns();
  }

  // =================== PREPAID PACKAGES ===================
  Future<void> savePackages() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPackages, jsonEncode(_packages.map((e) => e.toJson()).toList()));
  }

  Future<void> addPackage(PrepaidPackageItem item) async {
    _packages.add(item);
    await savePackages();
  }

  Future<void> updatePackage(PrepaidPackageItem item) async {
    final idx = _packages.indexWhere((p) => p.id == item.id);
    if (idx != -1) {
      _packages[idx] = item;
      await savePackages();
    }
  }

  Future<void> deletePackage(String id) async {
    _packages.removeWhere((p) => p.id == id);
    await savePackages();
  }

  // =================== MAINTENANCE MILESTONES ===================
  Future<void> saveMilestones() async {
    _milestones.sort((a, b) => a.km.compareTo(b.km));
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMilestones, jsonEncode(_milestones.map((e) => e.toJson()).toList()));
  }

  Future<void> addMilestone(MaintenanceMilestone item) async {
    _milestones.add(item);
    await saveMilestones();
  }

  Future<void> updateMilestone(MaintenanceMilestone item) async {
    final idx = _milestones.indexWhere((m) => m.id == item.id);
    if (idx != -1) {
      _milestones[idx] = item;
      await saveMilestones();
    }
  }

  Future<void> deleteMilestone(String id) async {
    _milestones.removeWhere((m) => m.id == id);
    await saveMilestones();
  }

  // =================== NEWS ===================
  Future<void> saveNews() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNews, jsonEncode(_newsList.map((e) => e.toJson()).toList()));
  }

  Future<void> addNews(NewsItem item) async {
    _newsList.insert(0, item);
    await saveNews();
  }

  Future<void> updateNews(NewsItem item) async {
    final idx = _newsList.indexWhere((n) => n.id == item.id);
    if (idx != -1) {
      _newsList[idx] = item;
      await saveNews();
    }
  }

  Future<void> deleteNews(String id) async {
    _newsList.removeWhere((n) => n.id == id);
    await saveNews();
  }

  // =================== VOUCHERS ===================
  Future<void> saveVouchers() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVouchers, jsonEncode(_vouchers.map((e) => e.toJson()).toList()));
  }

  Future<void> addVoucher(RewardVoucherItem item) async {
    _vouchers.add(item);
    await saveVouchers();
  }

  Future<void> updateVoucher(RewardVoucherItem item) async {
    final idx = _vouchers.indexWhere((v) => v.id == item.id);
    if (idx != -1) {
      _vouchers[idx] = item;
      await saveVouchers();
    }
  }

  Future<void> deleteVoucher(String id) async {
    _vouchers.removeWhere((v) => v.id == id);
    await saveVouchers();
  }

  // =================== RESET TO DEFAULTS ===================
  Future<void> resetToDefaults() async {
    _storeInfo = StoreInfo.defaultInfo();
    _campaigns = CampaignItem.defaultCampaigns();
    _packages = PrepaidPackageItem.defaultPackages();
    _milestones = MaintenanceMilestone.defaultMilestones();
    _newsList = NewsItem.defaultNews();
    _vouchers = RewardVoucherItem.defaultVouchers();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStoreInfo);
    await prefs.remove(_keyCampaigns);
    await prefs.remove(_keyPackages);
    await prefs.remove(_keyMilestones);
    await prefs.remove(_keyNews);
    await prefs.remove(_keyVouchers);
  }
}
