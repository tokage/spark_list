import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:spark_list/base/provider_widget.dart';
import 'package:spark_list/generated/l10n.dart';
import 'package:spark_list/view_model/link_notion_view_model.dart';
import 'package:spark_list/widget/app_bar.dart';
import 'package:spark_list/widget/settings_list_item.dart';
import 'package:provider/provider.dart';

///
/// Author: Elemen
/// Github: https://github.com/elementlo
/// Date: 2022/1/11
/// Description:
///
enum _ExpandableSetting { textScale, time }

class LinkNotionPage extends StatefulWidget {
  const LinkNotionPage({Key? key}) : super(key: key);

  @override
  _LinkNotionPageState createState() => _LinkNotionPageState();
}

class _LinkNotionPageState extends State<LinkNotionPage>
    with TickerProviderStateMixin {
  late Animation<double> _staggerSettingsItemsAnimation;
  late AnimationController _settingsPanelController;
  _ExpandableSetting? _expandedSettingId;
  final TextEditingController _inputController = TextEditingController();

  void onTapSetting(_ExpandableSetting settingId) {
    setState(() {
      if (_expandedSettingId == settingId) {
        _expandedSettingId = null;
      } else {
        _expandedSettingId = settingId;
      }
    });
  }

  void _closeSettingId(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      setState(() {
        _expandedSettingId = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _settingsPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _settingsPanelController.addStatusListener(_closeSettingId);
    _staggerSettingsItemsAnimation = CurvedAnimation(
      parent: _settingsPanelController,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsListItems = [
      SettingsListItem<double>(
        title: S.of(context).notion,
        optionsMap: LinkedHashMap.of({1.0: DisplayOption('')}),
        selectedOption: MediaQuery.of(context).textScaleFactor,
        onOptionChanged: (value) {
          print(value);
        },
        onTapSetting: () => onTapSetting(_ExpandableSetting.textScale),
        isExpanded: _expandedSettingId == _ExpandableSetting.textScale,
        child: _NotionAccountCard(controller: _inputController,),
      ),
      SettingsListItem<double>(
        title: S.of(context).linkNotionDatabase,
        selectedOption: 1.0,
        optionsMap: LinkedHashMap.of({1.0: DisplayOption('')}),
        onOptionChanged: (newTextScale) {},
        onTapSetting: () => onTapSetting(_ExpandableSetting.time),
        isExpanded: _expandedSettingId == _ExpandableSetting.time,
        child: Container(),
      ),
    ];
    return ProviderWidget<LinkNotionViewModel>(
      model: LinkNotionViewModel(),
      child: Scaffold(
        appBar: SparkAppBar(
          context: context,
          title: S.of(context).bindNotion,
        ),
        body: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 64,
            ),
            // Remove ListView top padding as it is already accounted for.
            child: ListView(
              children: [
                const SizedBox(height: 12),
                ...[
                  _AnimateSettingsListItems(
                    animation: _staggerSettingsItemsAnimation,
                    children: settingsListItems,
                  ),
                  const SizedBox(height: 12),
                  //Divider(thickness: 2, height: 0, color: colorScheme.background),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimateSettingsListItems extends StatelessWidget {
  const _AnimateSettingsListItems({
    Key? key,
    required this.animation,
    required this.children,
  }) : super(key: key);

  final Animation<double> animation;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dividingPadding = 4.0;
    final topPaddingTween = Tween<double>(
      begin: 0,
      end: children.length * dividingPadding,
    );
    final dividerTween = Tween<double>(
      begin: 0,
      end: dividingPadding,
    );

    return Padding(
      padding: EdgeInsets.only(top: topPaddingTween.animate(animation).value),
      child: Column(
        children: [
          for (Widget child in children)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: dividerTween.animate(animation).value,
                  ),
                  child: child,
                );
              },
              child: child,
            ),
        ],
      ),
    );
  }
}

class _NotionAccountCard extends StatelessWidget {
  final TextEditingController controller;

  const _NotionAccountCard({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
                labelText: S.of(context).notionToken,
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                suffix: Container(
                  width: 25,
                  height: 25,
                  child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        if(controller.text.isNotEmpty){
                          context.read<LinkNotionViewModel>().syncUserInfo(controller.text);
                        }
                      },
                      icon: Icon(
                        Icons.check,
                        color: colorScheme.onSecondary,
                      )),
                ),
                contentPadding: EdgeInsets.only(top: 10)),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 0),
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 30,
              backgroundImage: NetworkImage(
                'https://t7.baidu.com/it/u=1819248061,230866778&fm=193&f=GIF',
              ),
            ),
            title: Text('1111'),
            subtitle: Text('2222'),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.title),
            ),
          ),
        ],
      ),
    );
  }
}
