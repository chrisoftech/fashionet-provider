import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';

const String HAS_PROFILE = 'hasProfile';
const String PROFILE_WIZARD_INDEX = 'profileWizardIndex';

const String SETTINGS = 'Settings';
const String POST_CATEGORIES = 'Categories';
const String SIGN_OUT = 'Signout';

const List<MenuOption> menuOptions = <MenuOption>[
  MenuOption(icon: Icons.settings, menuOption: SETTINGS),
  MenuOption(icon: Icons.category, menuOption: POST_CATEGORIES),
  MenuOption(icon: Icons.exit_to_app, menuOption: SIGN_OUT),
];
