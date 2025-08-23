import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';

/// Validate OpenRouter API key format
bool isValidOpenRouterApiKey(String apiKey) {
  if (apiKey.trim().isEmpty) {
    return false;
  }
  return apiKey.startsWith('sk-or-') && apiKey.length > 10;
}

/// Format token count for display
String formatTokenCount(int tokens) {
  if (tokens < 1000) {
    return tokens.toString();
  } else if (tokens < 1000000) {
    return '${(tokens / 1000).toStringAsFixed(1)}K';
  } else {
    return '${(tokens / 1000000).toStringAsFixed(1)}M';
  }
}

/// Calculate estimated cost for tokens (rough estimation in USD)
double estimateTokenCost(
  int promptTokens,
  int completionTokens,
  double promptRate,
  double completionRate,
) {
  final promptCost = (promptTokens / 1000000) * promptRate;
  final completionCost = (completionTokens / 1000000) * completionRate;
  return promptCost + completionCost;
}

/// Format cost for display
String formatCost(double cost) {
  if (cost < 0.001) {
    return '<\$0.001';
  } else if (cost < 1.0) {
    return '\$${cost.toStringAsFixed(3)}';
  } else {
    return '\$${cost.toStringAsFixed(2)}';
  }
}

/// Truncate text to specified length with ellipsis
String truncateText(
  String text,
  int maxLength,
) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength)}...';
}

/// Extract model provider from model ID
String extractModelProvider(String modelId) {
  final parts = modelId.split('/');
  if (parts.length >= 2) {
    return parts[0];
  }
  return 'Unknown';
}

/// Check if model is free based on ID
bool isModelFree(String modelId) {
  return modelId.contains(':free');
}

/// Generate a simple hash for string (for cache keys)
String generateStringHash(String input) {
  var hash = 0;
  for (var i = 0; i < input.length; i++) {
    hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xffffffff;
  }
  return hash.abs().toString();
}

/// Clean and prepare text for API request
String prepareTextForApi(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Count words in text
int countWords(String text) {
  if (text.trim().isEmpty) {
    return 0;
  }
  return text.trim().split(RegExp(r'\s+')).length;
}

/// Estimate reading time in minutes
int estimateReadingTime(String text) {
  final wordCount = countWords(text);
  // Average reading speed: 200 words per minute
  return math.max(1, (wordCount / 200).ceil());
}
