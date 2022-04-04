import 'package:flutter/material.dart';
import 'package:myvef_app/Home/Model/advice.dart';

import '../Config/Constant.dart';
import '../Config/GlobalWidget/GlobalWidget.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('테스트 페이지'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: globalAdviceList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                padding: EdgeInsets.fromLTRB(16 * sizeUnit, 24 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit),
                width: double.infinity,
                decoration:  BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  boxShadow: vfBasicBoxShadow,
                  borderRadius: BorderRadius.circular(20 * sizeUnit),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('오늘의 한마디', style: VfTextStyle.highlight3()),
                          SizedBox(height: 4 * sizeUnit),
                          Text(
                            '빵 굽는 수의사의 한마디',
                            style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * sizeUnit),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 14 * sizeUnit),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: vfColorPink20,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        checkToken(globalAdviceList[index].contents),
                        style: VfTextStyle.subTitle4().copyWith(height: 16 / 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },

          );
        },
      ),
    );
  }
}
