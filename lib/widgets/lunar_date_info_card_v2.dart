import 'package:common/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:common/models/chinese_date_info.dart';
import 'package:common/models/seventy_two_phenology.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/divination_datetime.dart';
import '../themes/gan_zhi_gua_colors.dart';

import '../helpers/solar_lunar_datetime_helper.dart';

class LunarDateInfoCardV2 extends StatelessWidget {
  final DateTimeDetailsBundle bundle;
  final EnumDatetimeType inUsed;
  final bool isHiddenDatetimeType;
  final double underlingWidth = 1.0;
  final String? cardChipTagStr;

  const LunarDateInfoCardV2({
    super.key,
    required this.bundle,
    required this.inUsed,
    this.isHiddenDatetimeType = false,
    this.cardChipTagStr,
  });

  Color get mainlyTextThemeColor =>
      AppColors.zodiacZhiColors[chineseDateInfo!.eightChars.month.diZhi]!;
  Color get timingTextThemeColor =>
      AppColors.zodiacZhiColors[chineseDateInfo!.eightChars.hourDiZhi]!;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final monthBranch = chineseDateInfo?.eightChars.month.diZhi;

    final themeData = monthBranch != null
        ? AppThemes.getThemeForDiZhi(
            monthBranch, isDarkMode ? Brightness.dark : Brightness.light)
        : (isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme);
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    if (cardChipTagStr != null) {
      padding = const EdgeInsets.fromLTRB(20, 20, 20, 10);
    }

    return Theme(
      data: themeData,
      child: Builder(builder: (context) {
        return Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 240, maxWidth: 420),
              child: Stack(
                children: [
                  Container(
                    padding: padding,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDateTimeSection(context),
                        _buildAstronomicalSection(context),
                        _buildSolarTermAndPhenologySection(context),
                        _buildFooterSection(context),
                      ],
                    ),
                  ),
                  if (cardChipTagStr != null)
                    Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCardChipTag(cardChipTagStr!))
                ],
              )),
        );
      }),
    );
  }

  Widget _buildCardChipTag(String tagStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomRight: Radius.circular(12),
        ),
        color: Colors.red,
      ),
      child: Text(
        tagStr,
        style: TextStyle(
          fontSize: 12,
          height: 1.1,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  ChineseDateInfo? get chineseDateInfo {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredChineseInfo;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTChineseInfo;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarChineseInfo;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarChineseInfo;
    }
  }

  DateTime? get dateTime {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredDatetime;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTDatetime;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarDatetime;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarDatetime;
    }
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSection(context),
        Expanded(child: SizedBox()),
        _buildTimeSection(context),
      ],
    );
  }

  Widget _buildTimeSection(BuildContext context) {
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.titleMedium?.color;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 18,
                color: secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('HH:mm').format(dateTime!),
                style: TextStyle(
                  fontFamily: 'DIN Alternate',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2), color: Colors.red),
            child: Text(
              "午时·六刻",
              style: TextStyle(
                fontSize: 9,
                height: 1.1,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ]);
  }

  Widget _buildDateSection(BuildContext context) {
    if (dateTime == null || chineseDateInfo == null) {
      return const SizedBox.shrink();
    }
    final eightChars = chineseDateInfo!.eightChars;
    final lunarMonthName = chineseDateInfo!.lunarMonth;
    final lunarDayName = chineseDateInfo!.lunarDay;
    final monthBranchName = eightChars.month.diZhi.asMonthToken.diZhi.name;
    final secondaryTextColor = Theme.of(context).textTheme.titleMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: cardChipTagStr == null ? 10 : 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('yyyy年MM月dd日').format(dateTime!),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (!isHiddenDatetimeType)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inUsed.name,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        // const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${eightChars.year.name}年 ${chineseDateInfo!.isLeapMonth ? "[闰]" : ""}${SolarLunarDateTimeHelper.intMonth2ChineseMap[lunarMonthName]}月${SolarLunarDateTimeHelper.intDay2ChineseMap[lunarDayName]}日 ${eightChars.time.diZhi.name}时',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${SolarLunarDateTimeHelper.intMonthTo4SeasonsMap[chineseDateInfo!.lunarMonth]}',
              style: TextStyle(
                fontSize: 14,
                color: mainlyTextThemeColor,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: '月令',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    monthBranchName,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.1,
                      color: mainlyTextThemeColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSolarTermAndPhenologySection(BuildContext context) {
    if (dateTime == null || chineseDateInfo == null) {
      return const SizedBox.shrink();
    }
    final jieQiInfo = chineseDateInfo!.jieQiInfo;
    final phenology = chineseDateInfo!.phenology;
    final now = dateTime!.millisecondsSinceEpoch;
    final start = jieQiInfo.startAt.millisecondsSinceEpoch;
    final end = jieQiInfo.endAt.millisecondsSinceEpoch;
    final progress = (now - start) / (end - start);
    final secondaryTextColor = Theme.of(context).textTheme.titleMedium?.color;

    final phenologies = Phenology.phenologyList
        .where((p) => p.jieqi == jieQiInfo.jieQi)
        .toList();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message:
                        '交节：${DateFormat('yyyy/MM/dd HH:mm:ss').format(jieQiInfo.startAt)}',
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Noto Sans SC',
                          color: secondaryTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${jieQiInfo.jieQi.name} ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: mainlyTextThemeColor,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat('MM/dd').format(jieQiInfo.startAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tooltip(
                    message:
                        '交节：${DateFormat('yyyy/MM/dd HH:mm:ss').format(jieQiInfo.endAt)}',
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Noto Sans SC',
                          color: secondaryTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${jieQiInfo.nextJieQi.name} ',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                              text:
                                  DateFormat('MM/dd').format(jieQiInfo.endAt)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: mainlyTextThemeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(phenologies.length, (index) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: phenologies[index] == phenology
                            ? mainlyTextThemeColor
                            : Colors.transparent,
                        width: underlingWidth,
                      ),
                    ),
                  ),
                  child: Text(
                    phenologies[index].name,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                if (index < phenologies.length - 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '·',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAstronomicalSection(BuildContext context) {
    final coordinates = bundle.coordinates ?? bundle.location?.coordinates;

    if (coordinates == null || dateTime == null) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
        ],
      );
    }

    // For development phase: using specific mock data as requested
    final mockYear = dateTime!.year;
    final mockMonth = dateTime!.month;
    final mockDay = dateTime!.day;
    final bool isUtc = dateTime!.isUtc;

    // IMPORTANT: We must construct mock times using the SAME timezone reference
    // as the dateTime from the card to ensure the comparison is valid.
    final location = tz.getLocation(bundle.timezoneStr);
    DateTime createTime(int hour, int minute) {
      if (isUtc) {
        return tz.TZDateTime.utc(mockYear, mockMonth, mockDay, hour, minute);
      }
      return tz.TZDateTime(
        location,
        mockYear,
        mockMonth,
        mockDay,
        hour,
        minute,
      );
    }

    DateTime mockSunRise = createTime(5, 17);
    DateTime mockSunSet = createTime(18, 42);
    DateTime mockMoonRise = createTime(9, 44);
    DateTime mockMoonSet = createTime(23, 44);

    // If coordinates are null, we still show the mockup for dev purposes
    // but in final version we should use calculateDaily
    /*
    final dailyInfo = CelestialRiseSetCalculator.calculateDaily(
      utcDateTime: dateTime!.toUtc(),
      longitude: coordinates?.longitude ?? 121.4726,
      latitude: coordinates?.latitude ?? 31.2317,
    );
    */

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildRiseSetSubSection(
              context,
              icon: Icons.wb_sunny_rounded,
              titleStart: '日出',
              titleEnd: '日落',
              rise: mockSunRise,
              down: mockSunSet,
              iconColor: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildRiseSetSubSection(
              context,
              icon: Icons.nightlight_round,
              titleStart: '月出',
              titleEnd: '月落',
              rise: mockMoonRise,
              down: mockMoonSet,
              iconColor: Colors.indigoAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiseSetSubSection(
    BuildContext context, {
    required IconData icon,
    required String titleStart,
    required String titleEnd,
    required Color iconColor,
    DateTime? rise,
    DateTime? down,
  }) {
    final secondaryTextColor = Theme.of(context).textTheme.titleMedium?.color;
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final progressColor = mainlyTextThemeColor;

    double progress = 0.0;
    if (rise != null && down != null && dateTime != null) {
      // Both rise/set and dateTime are now in the same timezone reference frame.
      // We can safely use their hour/minute components or total duration.

      final totalMinutes = down.difference(rise).inMinutes;
      final currentMinutes = dateTime!.difference(rise).inMinutes;
      // debugPrint("rise: $rise, down: $down, dateTime: $dateTime");
      // debugPrint(
      //     'totalMinutes: $totalMinutes, currentMinutes: $currentMinutes');

      if (currentMinutes >= 0 && currentMinutes <= totalMinutes) {
        progress = currentMinutes / totalMinutes;
      } else if (currentMinutes > totalMinutes) {
        progress = 1.0;
      }
    }
    // debugPrint('progress: $progress');

    String formatTime(DateTime? dt) {
      if (dt == null) return '--:--';
      // Mock data is already local
      return DateFormat('HH:mm').format(dt);
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                titleStart,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Noto Sans SC',
                  color: secondaryTextColor?.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                titleEnd,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Noto Sans SC',
                  color: secondaryTextColor?.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Custom High-Contrast Progress Bar
          SizedBox(
            height: 6,
            width: double.infinity,
            child: Stack(
              children: [
                // Track - Increased contrast for visibility
                Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Progress Filler - Vibrant with shadow
                if (progress > 0)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.005, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: timingTextThemeColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: timingTextThemeColor.withValues(alpha: 0.2),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTime(rise),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DIN Alternate',
                  color: primaryTextColor,
                ),
              ),
              Text(
                formatTime(down),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DIN Alternate',
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6);
    final coordinates = bundle.coordinates ?? bundle.location?.coordinates;
    final timezone = bundle.timezoneStr;
    final address = bundle.location?.address;

    List<String> addressParts = [];
    if (address != null) {
      addressParts.add(address.countryName);
      if (address.province.name != address.countryName) {
        addressParts.add(address.province.name);
      }
      if (address.city != null && address.city!.name != address.province.name) {
        addressParts.add(address.city!.name);
      }
      if (address.area != null) {
        addressParts.add(address.area!.name);
      }
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Divider(
          color: Theme.of(context).dividerColor,
          height: 1,
        ),
        const SizedBox(height: 8),
        if (addressParts.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.place_outlined, size: 12, color: secondaryTextColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  addressParts.join(' · '),
                  style: TextStyle(
                    fontSize: 10,
                    color: secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (coordinates != null)
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 12, color: secondaryTextColor),
                  const SizedBox(width: 4),
                  Text(
                    '经度 ${coordinates.longitude.toStringAsFixed(4)}°, 纬度 ${coordinates.latitude.toStringAsFixed(4)}°',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'DIN Alternate',
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Icon(Icons.language, size: 12, color: secondaryTextColor),
                const SizedBox(width: 4),
                Text(
                  '时区: $timezone',
                  style: TextStyle(
                    fontSize: 10,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
