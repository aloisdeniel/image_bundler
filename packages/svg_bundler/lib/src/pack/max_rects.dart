// Dart implementation of MaxRectsBinPack based on the C++ source from https://github.com/juj/RectangleBinPack/blob/master/MaxRectsBinPack.cpp

class Rect {
  int x, y, width, height;

  Rect({this.x = 0, this.y = 0, this.width = 0, this.height = 0});

  @override
  String toString() => 'Rect(x: $x, y: $y, width: $width, height: $height)';
}

enum FreeRectChoiceHeuristic {
  bestShortSideFit, // BSSF: Positions the rectangle against the short side of a free rectangle into which it fits the best.
  bestLongSideFit, // BLSF: Positions the rectangle against the long side of a free rectangle into which it fits the best.
  bestAreaFit, // BAF: Positions the rectangle into the smallest free rect into which it fits.
  bottomLeftRule, // BL: Does the Tetris placement.
  contactPointRule, // CP: Choosest the placement where the rectangle touches other rects as much as possible.
}

class MaxRectsBinPack {
  int binWidth;
  int binHeight;
  bool allowRotations;

  List<Rect> usedRectangles = [];
  List<Rect> freeRectangles = [];

  MaxRectsBinPack(this.binWidth, this.binHeight, {this.allowRotations = true}) {
    freeRectangles.add(Rect(x: 0, y: 0, width: binWidth, height: binHeight));
  }

  Rect insert(int width, int height, FreeRectChoiceHeuristic method) {
    Rect newNode = Rect();
    int score1 = 0; // Unused in some methods.
    int score2 = 0;
    switch (method) {
      case FreeRectChoiceHeuristic.bestShortSideFit:
        newNode = _findPositionForNewNodeBestShortSideFit(
          width,
          height,
          score1,
          score2,
        );
        break;
      case FreeRectChoiceHeuristic.bestLongSideFit:
        newNode = _findPositionForNewNodeBestLongSideFit(
          width,
          height,
          score1,
          score2,
        );
        break;
      case FreeRectChoiceHeuristic.bestAreaFit:
        newNode = _findPositionForNewNodeBestAreaFit(
          width,
          height,
          score1,
          score2,
        );
        break;
      case FreeRectChoiceHeuristic.bottomLeftRule:
        newNode = _findPositionForNewNodeBottomLeft(
          width,
          height,
          score1,
          score2,
        );
        break;
      case FreeRectChoiceHeuristic.contactPointRule:
        newNode = _findPositionForNewNodeContactPoint(width, height, score1);
        break;
    }

    if (newNode.height == 0) {
      return newNode; // Failed to find a position
    }

    _placeRect(newNode);
    return newNode;
  }

  void _placeRect(Rect node) {
    int numRectanglesToProcess = freeRectangles.length;
    for (int i = 0; i < numRectanglesToProcess; i++) {
      if (_splitFreeNode(freeRectangles[i], node)) {
        freeRectangles.removeAt(i);
        i--;
        numRectanglesToProcess--;
      }
    }
    _pruneFreeList();
    usedRectangles.add(node);
  }

  bool _splitFreeNode(Rect freeNode, Rect usedNode) {
    // Implementation of splitting free node logic
    if (usedNode.x >= freeNode.x + freeNode.width ||
        usedNode.x + usedNode.width <= freeNode.x ||
        usedNode.y >= freeNode.y + freeNode.height ||
        usedNode.y + usedNode.height <= freeNode.y) {
      return false;
    }

    if (usedNode.x < freeNode.x + freeNode.width &&
        usedNode.x + usedNode.width > freeNode.x) {
      // New node at the top side of the used node.
      if (usedNode.y > freeNode.y &&
          usedNode.y < freeNode.y + freeNode.height) {
        Rect newNode = Rect(
          x: freeNode.x,
          y: freeNode.y,
          width: freeNode.width,
          height: usedNode.y - freeNode.y,
        );
        freeRectangles.add(newNode);
      }

      // New node at the bottom side of the used node.
      if (usedNode.y + usedNode.height < freeNode.y + freeNode.height) {
        Rect newNode = Rect(
          x: freeNode.x,
          y: usedNode.y + usedNode.height,
          width: freeNode.width,
          height: freeNode.y + freeNode.height - (usedNode.y + usedNode.height),
        );
        freeRectangles.add(newNode);
      }
    }

    if (usedNode.y < freeNode.y + freeNode.height &&
        usedNode.y + usedNode.height > freeNode.y) {
      // New node at the left side of the used node.
      if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width) {
        Rect newNode = Rect(
          x: freeNode.x,
          y: freeNode.y,
          width: usedNode.x - freeNode.x,
          height: freeNode.height,
        );
        freeRectangles.add(newNode);
      }

      // New node at the right side of the used node.
      if (usedNode.x + usedNode.width < freeNode.x + freeNode.width) {
        Rect newNode = Rect(
          x: usedNode.x + usedNode.width,
          y: freeNode.y,
          width: freeNode.x + freeNode.width - (usedNode.x + usedNode.width),
          height: freeNode.height,
        );
        freeRectangles.add(newNode);
      }
    }

    return true;
  }

  void _pruneFreeList() {
    for (int i = 0; i < freeRectangles.length; i++) {
      for (int j = i + 1; j < freeRectangles.length; j++) {
        if (_isContainedIn(freeRectangles[i], freeRectangles[j])) {
          freeRectangles.removeAt(i);
          i--;
          break;
        }
        if (_isContainedIn(freeRectangles[j], freeRectangles[i])) {
          freeRectangles.removeAt(j);
          j--;
        }
      }
    }
  }

  bool _isContainedIn(Rect a, Rect b) {
    return a.x >= b.x &&
        a.y >= b.y &&
        a.x + a.width <= b.x + b.width &&
        a.y + a.height <= b.y + b.height;
  }

  Rect _findPositionForNewNodeBestShortSideFit(
    int width,
    int height,
    int score1,
    int score2,
  ) {
    Rect bestNode = Rect();
    score1 = 0x7fffffff;
    score2 = 0x7fffffff;

    for (Rect freeRect in freeRectangles) {
      // Try to place the rectangle upright.
      if (freeRect.width >= width && freeRect.height >= height) {
        int leftoverHoriz = (freeRect.width - width).abs();
        int leftoverVert = (freeRect.height - height).abs();
        int shortSideFit =
            leftoverHoriz < leftoverVert ? leftoverHoriz : leftoverVert;
        int longSideFit =
            leftoverHoriz > leftoverVert ? leftoverHoriz : leftoverVert;

        if (shortSideFit < score1 ||
            (shortSideFit == score1 && longSideFit < score2)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = width;
          bestNode.height = height;
          score1 = shortSideFit;
          score2 = longSideFit;
        }
      }

      if (allowRotations &&
          freeRect.width >= height &&
          freeRect.height >= width) {
        int leftoverHoriz = (freeRect.width - height).abs();
        int leftoverVert = (freeRect.height - width).abs();
        int shortSideFit =
            leftoverHoriz < leftoverVert ? leftoverHoriz : leftoverVert;
        int longSideFit =
            leftoverHoriz > leftoverVert ? leftoverHoriz : leftoverVert;

        if (shortSideFit < score1 ||
            (shortSideFit == score1 && longSideFit < score2)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = height;
          bestNode.height = width;
          score1 = shortSideFit;
          score2 = longSideFit;
        }
      }
    }

    return bestNode;
  }

  Rect _findPositionForNewNodeBestLongSideFit(
    int width,
    int height,
    int score1,
    int score2,
  ) {
    Rect bestNode = Rect();
    score2 = 0x7fffffff;
    score1 = 0x7fffffff;

    for (Rect freeRect in freeRectangles) {
      if (freeRect.width >= width && freeRect.height >= height) {
        int leftoverHoriz = (freeRect.width - width).abs();
        int leftoverVert = (freeRect.height - height).abs();
        int shortSideFit =
            leftoverHoriz < leftoverVert ? leftoverHoriz : leftoverVert;
        int longSideFit =
            leftoverHoriz > leftoverVert ? leftoverHoriz : leftoverVert;

        if (longSideFit < score2 ||
            (longSideFit == score2 && shortSideFit < score1)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = width;
          bestNode.height = height;
          score1 = shortSideFit;
          score2 = longSideFit;
        }
      }

      if (allowRotations &&
          freeRect.width >= height &&
          freeRect.height >= width) {
        int leftoverHoriz = (freeRect.width - height).abs();
        int leftoverVert = (freeRect.height - width).abs();
        int shortSideFit =
            leftoverHoriz < leftoverVert ? leftoverHoriz : leftoverVert;
        int longSideFit =
            leftoverHoriz > leftoverVert ? leftoverHoriz : leftoverVert;

        if (longSideFit < score2 ||
            (longSideFit == score2 && shortSideFit < score1)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = height;
          bestNode.height = width;
          score1 = shortSideFit;
          score2 = longSideFit;
        }
      }
    }

    return bestNode;
  }

  Rect _findPositionForNewNodeBestAreaFit(
    int width,
    int height,
    int score1,
    int score2,
  ) {
    Rect bestNode = Rect();
    score1 = 0x7fffffff;
    score2 = 0x7fffffff;
    int bestAreaFit = 0x7fffffff;

    for (Rect freeRect in freeRectangles) {
      int areaFit = freeRect.width * freeRect.height - width * height;

      if (freeRect.width >= width && freeRect.height >= height) {
        if (areaFit < bestAreaFit ||
            (areaFit == bestAreaFit && freeRect.width < score1)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = width;
          bestNode.height = height;
          score1 = freeRect.width;
          score2 = areaFit;
          bestAreaFit = areaFit;
        }
      }

      if (allowRotations &&
          freeRect.width >= height &&
          freeRect.height >= width) {
        if (areaFit < bestAreaFit ||
            (areaFit == bestAreaFit && freeRect.width < score1)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = height;
          bestNode.height = width;
          score1 = freeRect.width;
          score2 = areaFit;
          bestAreaFit = areaFit;
        }
      }
    }

    return bestNode;
  }

  Rect _findPositionForNewNodeBottomLeft(
    int width,
    int height,
    int score1,
    int score2,
  ) {
    Rect bestNode = Rect();
    score1 = 0x7fffffff;
    score2 = 0x7fffffff;

    for (Rect freeRect in freeRectangles) {
      if (freeRect.width >= width && freeRect.height >= height) {
        int topSideY = freeRect.y + height;
        if (topSideY < score1 || (topSideY == score1 && freeRect.x < score2)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = width;
          bestNode.height = height;
          score1 = topSideY;
          score2 = freeRect.x;
        }
      }

      if (allowRotations &&
          freeRect.width >= height &&
          freeRect.height >= width) {
        int topSideY = freeRect.y + width;
        if (topSideY < score1 || (topSideY == score1 && freeRect.x < score2)) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = height;
          bestNode.height = width;
          score1 = topSideY;
          score2 = freeRect.x;
        }
      }
    }

    return bestNode;
  }

  Rect _findPositionForNewNodeContactPoint(int width, int height, int score1) {
    Rect bestNode = Rect();
    score1 = -1;

    for (Rect freeRect in freeRectangles) {
      if (freeRect.width >= width && freeRect.height >= height) {
        int score = _contactPointScoreNode(
          freeRect.x,
          freeRect.y,
          width,
          height,
        );
        if (score > score1) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = width;
          bestNode.height = height;
          score1 = score;
        }
      }

      if (allowRotations &&
          freeRect.width >= height &&
          freeRect.height >= width) {
        int score = _contactPointScoreNode(
          freeRect.x,
          freeRect.y,
          height,
          width,
        );
        if (score > score1) {
          bestNode.x = freeRect.x;
          bestNode.y = freeRect.y;
          bestNode.width = height;
          bestNode.height = width;
          score1 = score;
        }
      }
    }

    return bestNode;
  }

  int _contactPointScoreNode(int x, int y, int width, int height) {
    int score = 0;

    if (x == 0 || x + width == binWidth) {
      score += height;
    }
    if (y == 0 || y + height == binHeight) {
      score += width;
    }

    for (Rect usedRect in usedRectangles) {
      if (usedRect.x == x + width || usedRect.x + usedRect.width == x) {
        int verticalOverlap = _commonIntervalLength(
          usedRect.y,
          usedRect.y + usedRect.height,
          y,
          y + height,
        );
        score += verticalOverlap;
      }
      if (usedRect.y == y + height || usedRect.y + usedRect.height == y) {
        int horizontalOverlap = _commonIntervalLength(
          usedRect.x,
          usedRect.x + usedRect.width,
          x,
          x + width,
        );
        score += horizontalOverlap;
      }
    }

    return score;
  }

  int _commonIntervalLength(int i1start, int i1end, int i2start, int i2end) {
    if (i1end < i2start || i2end < i1start) {
      return 0;
    }
    return (i1end < i2end ? i1end : i2end) -
        (i1start > i2start ? i1start : i2start);
  }
}
