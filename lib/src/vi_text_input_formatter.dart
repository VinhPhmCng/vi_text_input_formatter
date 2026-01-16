import 'package:flutter/services.dart';

part 'vi_maps.dart';

/// Converts the current word to Vietnamese, mimicking Unikey (Unicode, Telex)
class ViTextInputFormatter extends TextInputFormatter {
  /// Initializes helper List
  ViTextInputFormatter() {
    final allVowels = <String>[];
    for (final vowAndMod in vowelAndModifierToVowel.keys) {
      final vowel = vowAndMod.left(-1);
      if (!allVowels.contains(vowel)) {
        allVowels.add(vowel);
      }
    }
    for (final vowAndMod in vowelAndModifierToVowelWithTrailingConsonant.keys) {
      final vowel = vowAndMod.left(-1);
      if (!allVowels.contains(vowel)) {
        allVowels.add(vowel);
      }
    }
    allVowels.sort((a, b) => b.length.compareTo(a.length));
    _vowels = List<String>.from(allVowels);
  }

  late final List<String> _vowels;

  /// Converts the current word to Vietnamese, mimicking Unikey (Unicode, Telex)
  String toVn(String text, {required bool isDeletion}) {
    var leadingConsonant = '';
    var vowelAndModifier = '';
    var vowel = '';
    var trailingConsonant = '';

    if (isDeletion) {
      for (final leadingCon in leadingConsonants) {
        if (text.startsWith(leadingCon)) {
          leadingConsonant = leadingCon;
          break;
        }
      }

      final afterLeadingConsonant = text.right(-leadingConsonant.length);
      if (vowelAfterDeletionToVowel.containsKey(afterLeadingConsonant)) {
        // xoáy - y -> xóa
        final newVowel = vowelAfterDeletionToVowel[afterLeadingConsonant]!;
        return '$leadingConsonant$newVowel';
      }
      return text;
    }

    // Is insertion
    final firstCharacter = text.left(1);
    final addedCharacter = text.right(1);

    //  Handle 'd' insertion
    if (firstCharacter == 'd' && addedCharacter == 'd' && text.length >= 2) {
      return 'đ${text.right(-1).left(-1)}';
    }
    if (firstCharacter == 'đ' && addedCharacter == 'd') {
      return 'd${text.right(-1).left(-1)}d';
    }

    // Handle 'gi'
    if (giAndModifierToGi.containsKey(text)) {
      return giAndModifierToGi[text]!;
    }
    if (giAndModifierToGiAndVowel.containsKey(text)) {
      return giAndModifierToGiAndVowel[text]!;
    }

    // Split
    for (final leadingCons in leadingConsonants) {
      if (text.startsWith(leadingCons)) {
        leadingConsonant = leadingCons;
        break;
      }
    }

    final afterLeadingConsonant = text.right(-leadingConsonant.length);
    if (vowelAndModifierToVowel.containsKey(afterLeadingConsonant)) {
      final newVowel = vowelAndModifierToVowel[afterLeadingConsonant]!;
      return '$leadingConsonant$newVowel';
    }

    // Doesn't end with a [vowelAndModifier]
    for (final vow in _vowels) {
      if (afterLeadingConsonant != vow &&
          afterLeadingConsonant.startsWith(vow)) {
        vowel = vow;
        break;
      }
    }
    if (vowel.isNotEmpty) {
      // Has a vowel
      final afterVowel = afterLeadingConsonant.right(-vowel.length);
      if (trailingConsonants.contains(afterVowel)) {
        // Insertion is a trailing consonant.
        if (vowelToVowelWithTrailingConsonant.containsKey(vowel)) {
          // khóa -> khoán
          final newVowel = vowelToVowelWithTrailingConsonant[vowel]!;
          return '$leadingConsonant$newVowel$afterVowel';
        }
        // bó -> bón
        return text;
      }

      // Insertion is not a trailing consonant.
      for (final trailingCon in trailingConsonants) {
        if (afterVowel.startsWith(trailingCon)) {
          trailingConsonant = trailingCon;
          break;
        }
      }
      if (trailingConsonant.isNotEmpty) {
        // Has a trailing consonant
        final afterTrailingConsonant = afterVowel.right(
          -trailingConsonant.length,
        );
        if (modifiers.contains(afterTrailingConsonant)) {
          // Insertion is a modifier. The word has a consonant between
          // the vowel and said modifier.
          // e.g. hoánf -> hoàn, khốnz -> khôn
          vowelAndModifier = '$vowel$afterTrailingConsonant';

          // Check for words whose trailing consonant affects the position of
          // the accent
          if (vowelAndModifierToVowelWithTrailingConsonant.containsKey(
            vowelAndModifier,
          )) {
            final newVowel =
                vowelAndModifierToVowelWithTrailingConsonant[vowelAndModifier]!;
            return newVowel.length > vowel.length
                // khoán + s -> khoans (and not khoasn)
                ? '''$leadingConsonant${newVowel.left(-1)}$trailingConsonant${newVowel.right(1)}'''
                // khoan + s -> khoán
                : '$leadingConsonant$newVowel$trailingConsonant';
          }

          // Then check for words whose accent stays the same place regardless
          // of the trailing consonant
          if (vowelAndModifierToVowel.containsKey(vowelAndModifier)) {
            final newVowel = vowelAndModifierToVowel[vowelAndModifier]!;
            return newVowel.length > vowel.length
                // mâm + a -> mama (and not maam)
                ? '''$leadingConsonant${newVowel.left(-1)}$trailingConsonant${newVowel.right(1)}'''
                // mam + a -> mâm
                : '$leadingConsonant$newVowel$trailingConsonant';
          }

          return text;
        }
      }
    }
    return text;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.selection.isValid) {
      return oldValue;
    }

    // Get current word and split the string into
    // [before] + [currentWord] + [after]
    String? currentWord;
    int? currentWordStart;
    int? currentWordEnd;

    final wordRegex = RegExp(r'\p{L}+', unicode: true);
    for (final match in wordRegex.allMatches(newValue.text)) {
      if (newValue.selection.baseOffset >= match.start &&
          newValue.selection.baseOffset <= match.end) {
        currentWord = match.group(0);
        currentWordStart = match.start;
        currentWordEnd = match.end;
        break;
      }
    }

    if (currentWord == null) {
      return newValue;
    }

    final before = newValue.text.substring(0, currentWordStart);
    final after = newValue.text.substring(currentWordEnd!);

    // Conversion
    final isDeletion = oldValue.text.length > newValue.text.length;
    if (isDeletion) {
      final vn = toVn(currentWord, isDeletion: true);
      final newText = '$before$vn$after';
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset:
              (newValue.selection.baseOffset +
                      newText.length -
                      newValue.text.length)
                  .clamp(0, newText.length),
        ),
      );
    }

    // Insertion
    if (currentWord.endsWith('w')) {
      currentWord = '${currentWord.left(-1)}ư';
    }
    final vn = toVn(currentWord, isDeletion: false);
    final newText = '$before$vn$after';
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            (newValue.selection.baseOffset +
                    newText.length -
                    newValue.text.length)
                .clamp(0, newText.length),
      ),
    );
  }
}

extension _GDScriptLikeStringExt on String {
  /// Returns the first [length] characters from the beginning. If [length] is
  /// negative, strips the last [length] characters from the string's end.
  String left(int length) {
    if (length == 0) {
      return this;
    } else if (length > 0) {
      if (length >= this.length) return this;
      return substring(0, length);
    } else {
      final trimCount = -length;
      if (trimCount >= this.length) return '';
      return substring(0, this.length - trimCount);
    }
  }

  /// Returns the last [length] characters from the end. If [length] is
  /// negative, strips the first [length] characters from the string's beginning
  /// .
  String right(int length) {
    if (length == 0) {
      return this;
    } else if (length > 0) {
      if (length >= this.length) return this;
      return substring(this.length - length);
    } else {
      final trimCount = -length;
      if (trimCount >= this.length) return '';
      return substring(trimCount);
    }
  }
}
