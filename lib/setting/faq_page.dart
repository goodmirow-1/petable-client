import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';

import '../Config/Constant.dart';
import '../Config/GlobalFunction.dart';
import '../Config/GlobalWidget/GlobalWidget.dart';
import '../Data/global_data.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {

  List<FAQ> faqList = [];
  List<FAQ> faqSearchList = [];
  List<FAQ> showList = [];

  final TextEditingController searchTextController = TextEditingController();

  bool isOnSearch = false;

  void searchFunc(String value) {
    if (searchTextController.text.isEmpty) {
      //검색창 비었으면
      isOnSearch = false;
    } else {
      isOnSearch = true;
      //검색어에 따라 재검색
      faqSearchList.clear();
      faqList.forEach((FAQ faq) {
        if (faq.category.contains(value) || faq.title.contains(value) || faq.description.contains(value)) {
          faqSearchList.add(faq);
        }
      });
      showList.clear();
      showList.addAll(faqSearchList);
    }
  }

  @override
  void initState() {
    faqList.addAll(GlobalData.faqList);
    showList.addAll(faqList);
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listWidget = [];
    showList.forEach((element) {listWidget.add(FAQWidget(element));});
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(context, title: '자주 묻는 질문'),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
            child: Column(
              children: [
                searchText(),
                SizedBox(height: 16 * sizeUnit),
                Expanded(
                  child: showList.length == 0
                      ? noSearchResultWidget()
                      : ListView.builder(
                          itemCount: showList.length,
                          itemBuilder: (BuildContext context, int index){
                            return FAQWidget(showList[index]);
                          },
                        ),
                ),
              ],
            ), // 기기 등록 시
          ),
        ),
      ),
    );
  }

  Widget searchText() {
    return vfTextField(
      textEditingController: searchTextController,
      borderColor: Colors.transparent,
      suffixIcon: IconButton(
        // 아이콘을 눌렀는지 여부에 따라 아이콘 색상 구별
        icon: isOnSearch ? SvgPicture.asset(svgMagnifyingGlassBlack) : SvgPicture.asset(svgMagnifyingGlassGray),
        onPressed: () {},
      ),
      onChanged: (value) {
        // 검색 버튼 눌림 여부가 실시간으로 변경되도록
        if (searchTextController.text.isNotEmpty) {
          isOnSearch = true;
          searchFunc(value);
        } else {
          isOnSearch = false;
          showList.clear();
          showList.addAll(faqList);
        }
        setState(() {});
      },
    );
  }
}

class FAQ {
  final String category;
  final String title;
  final String description;

  FAQ({required this.category, required this.title, required this.description});
}

class FAQWidget extends StatefulWidget {
  final FAQ faq;

  const FAQWidget(this.faq, {Key? key}) : super(key: key);

  @override
  State<FAQWidget> createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {
  bool isOpen = false;
  late FAQ _faq;

  @override
  void initState() {
    _faq = widget.faq;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _faq = widget.faq;
    return GestureDetector(
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 16 * sizeUnit, 8 * sizeUnit),
        margin: EdgeInsets.only(bottom: 8 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20 * sizeUnit),
          boxShadow: vfBasicBoxShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 264 * sizeUnit,
                  child: Text.rich(
                    TextSpan(
                      text: '[' + _faq.category + '] ',
                      children: [
                        TextSpan(text: _faq.title),
                      ],
                    ),
                    style: VfTextStyle.subTitle3(),
                  ),
                ),
                SvgPicture.asset(
                  isOpen ? svgArrowUp : svgArrowDown,
                  height: 24 * sizeUnit,
                  width: 24 * sizeUnit,
                ),
              ],
            ),
            if (isOpen) ...[
              SizedBox(height: 6 * sizeUnit),
              Container(
                width: 296 * sizeUnit,
                height: 1,
                color: vfColorGrey,
              ),
              SizedBox(height: 10 * sizeUnit),
              Text(
                _faq.description,
                style: VfTextStyle.body2().copyWith(height: 18/12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> getFAQData() async {

  var tsv = await rootBundle.loadString('assets/text/faq.tsv');

  List<String> tsvSplit = tsv.split('\n');

  // 행들의 집합
  tsvSplit.removeAt(0);//헤더 줄 제거
  List<String> tsvRows = tsvSplit;

  for (int i = 0; i < tsvRows.length; i++) {
    List<String> faqStringList = tsvRows[i].split('\t');

    FAQ faq = FAQ(category: faqStringList[0], title: faqStringList[1], description: faqStringList[2]);

    GlobalData.faqList.add(faq);
  }
}