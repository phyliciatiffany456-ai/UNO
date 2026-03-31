import 'package:flutter/material.dart';

enum ConnectionTab { followers, following }

class ProfileConnectionsPage extends StatefulWidget {
  const ProfileConnectionsPage({super.key, required this.initialTab});

  final ConnectionTab initialTab;

  @override
  State<ProfileConnectionsPage> createState() => _ProfileConnectionsPageState();
}

class _ProfileConnectionsPageState extends State<ProfileConnectionsPage> {
  late ConnectionTab _activeTab;

  final List<String> _followers = const <String>[
    'Rani HRD',
    'Fajar Dev',
    'Nadia PM',
    'Arga UX',
    'Dita Data',
  ];

  final List<String> _following = const <String>[
    'TiffanyPhylicia',
    'NexaTech Careers',
    'Agus Backend',
    'Riko Frontend',
    'Salsa Recruiter',
  ];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final bool showFollowers = _activeTab == ConnectionTab.followers;
    final List<String> data = showFollowers ? _followers : _following;

    return Scaffold(
      appBar: AppBar(
        title: Text(showFollowers ? 'Pengikut' : 'Mengikuti'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: _tabButton(
                    label: 'Pengikut',
                    active: showFollowers,
                    onTap: () {
                      setState(() {
                        _activeTab = ConnectionTab.followers;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _tabButton(
                    label: 'Mengikuti',
                    active: !showFollowers,
                    onTap: () {
                      setState(() {
                        _activeTab = ConnectionTab.following;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              itemCount: data.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13151A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF24262E)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Color(0xFFE5E7EB),
                        child: Icon(
                          Icons.person,
                          size: 15,
                          color: Color(0xFF121417),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF6A2D) : const Color(0xFF0E1014),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFFF6A2D) : const Color(0xFF2D313B),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
