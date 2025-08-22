import 'package:flutter/material.dart';

class PromptManagementPage extends StatelessWidget {
  const PromptManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt管理'),
      ),
      body: const Center(
        child: Text('Prompt管理页面 - 开发中'),
      ),
    );
  }
}

class FilterHistoryPage extends StatelessWidget {
  const FilterHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('过滤历史'),
      ),
      body: const Center(
        child: Text('过滤历史页面 - 开发中'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: const Center(
        child: Text('设置页面 - 开发中'),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: const Center(
        child: Text('关于页面 - 开发中'),
      ),
    );
  }
}