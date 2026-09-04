import 'package:flutter/material.dart';

class Topbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? userName;
  final String? userRole;
  final String? avatarImageUrl;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onLogout;
  final VoidCallback? onSettingsTap;
  final int notificationCount;
  final bool showMenuButton;
  final bool showNotifications;
  final bool showProfile;
  final bool showLogout;
  final bool showSettings;
  final Widget? leading;
  final List<Widget>? actions;

  const Topbar({
    super.key,
    required this.title,
    this.subtitle,
    this.userName,
    this.userRole,
    this.avatarImageUrl,
    this.onMenuTap,
    this.onProfileTap,
    this.onNotificationsTap,
    this.onLogout,
    this.onSettingsTap,
    this.notificationCount = 0,
    this.showMenuButton = true,
    this.showNotifications = true,
    this.showProfile = true,
    this.showLogout = false,
    this.showSettings = false,
    this.leading,
    this.actions,
  });

  String _initials() {
    final value = userName?.trim() ?? '';

    if (value.isEmpty) {
      return '?';
    }

    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Widget _notificationButton(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: onNotificationsTap,
          icon: const Icon(
            Icons.notifications_none_outlined,
          ),
        ),
        if (notificationCount > 0)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                notificationCount > 99
                    ? '99+'
                    : '$notificationCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profileButton(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  theme.colorScheme.primaryContainer,
              foregroundColor:
                  theme.colorScheme.primary,
              backgroundImage:
                  avatarImageUrl != null &&
                          avatarImageUrl!.trim().isNotEmpty
                      ? NetworkImage(avatarImageUrl!)
                      : null,
              child: avatarImageUrl == null ||
                      avatarImageUrl!.trim().isEmpty
                  ? Text(
                      _initials(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (userName != null &&
                userName!.trim().isNotEmpty) ...[
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 150,
                    ),
                    child: Text(
                      userName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userRole != null &&
                      userRole!.trim().isNotEmpty)
                    Text(
                      userRole!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      onSelected: (value) {
        switch (value) {
          case 'profile':
            onProfileTap?.call();
            break;
          case 'settings':
            onSettingsTap?.call();
            break;
          case 'logout':
            onLogout?.call();
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (onProfileTap != null)
            const PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.person_outline,
                ),
                title: Text('Profile'),
              ),
            ),
          if (showSettings && onSettingsTap != null)
            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.settings_outlined,
                ),
                title: Text('Settings'),
              ),
            ),
          if (showLogout && onLogout != null)
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.logout,
                ),
                title: Text('Logout'),
              ),
            ),
        ];
      },
      child: _profileButton(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (showMenuButton)
                IconButton(
                  tooltip: 'Menu',
                  onPressed: onMenuTap,
                  icon: const Icon(
                    Icons.menu,
                  ),
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null &&
                        subtitle!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
              if (showNotifications)
                _notificationButton(context),
              if (showProfile &&
                  userName != null &&
                  userName!.trim().isNotEmpty)
                _profileMenu(context),
            ],
          ),
        ),
      ),
    );
  }
}