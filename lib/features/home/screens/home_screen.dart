import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 優化 AppBar 設計
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '任務管理',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent, // 透明背景
        // 可選：添加右側操作按鈕
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      // 設置漸層背景
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            CarouselSlider(
              options: CarouselOptions(
                height: 170,
                enlargeCenterPage: true,
                autoPlay: false,
                enlargeFactor: 0.2, // 添加這個參數控制放大效果
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                viewportFraction: 0.85, // 調整視窗比例
              ),
              items: List<Widget>.generate(3, (int index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0), // 增加圓角
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: switch (index) {
                        0 => [Colors.blue.shade300, Colors.blue.shade400],
                        1 => [Colors.green.shade300, Colors.green.shade400],
                        2 => [Colors.amber.shade300, Colors.amber.shade400],
                        _ => [Colors.grey.shade300, Colors.grey.shade400]
                      },
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              switch (index) {
                                0 => Icons.pending_actions,
                                1 => Icons.task_alt,
                                2 => Icons.running_with_errors,
                                _ => Icons.error
                              },
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              switch (index) {
                                0 => '待處理任務',
                                1 => '已完成任務',
                                2 => '進行中任務',
                                _ => '問題'
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            switch (index) {
                              0 => '10',
                              1 => '25',
                              2 => '100',
                              _ => ''
                            },
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      // 優化底部導航欄
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        elevation: 0, // 移除陰影
        height: 65, // 調整高度
        backgroundColor: Colors.white, // 純白背景
        indicatorColor: Colors.amber.shade100, // 更柔和的指示器顏色
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: '任務',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
