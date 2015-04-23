public final class SiteList:IDisposable
{
		private var sites:[Site];
		private var currentIndex:Int = 0;

		private var sorted:Bool;
		
		public init()
		{
			sites = [Site]();
            sorted = false;
		}

		public func dispose()
		{
				for site in sites
				{
					site.dispose();
				}
				sites.removeAll(keepCapacity: true);

		}
//
		public func push(site:Site)->UInt
		{
			sorted = false;
			sites.append(site);
            return UInt(sites.count)
		}

    public var length:Int
    {
        return sites.count
    }
		
		public func next()->Site?
		{
            assert(sorted, "SiteList::next()->  sites have not been sorted")

            if(currentIndex < sites.count)
			{
				return sites[currentIndex++];
			}
			else
			{
				return nil;
			}
		}

		func getSitesBounds()->Rectangle
		{
			if (sorted == false)
			{
				Site.sortSites(&sites);
				currentIndex = 0;
				sorted = true;
			}
			var xmin:Double, xmax:Double, ymin:Double, ymax:Double;
			if (sites.count == 0)
			{
				return Rectangle(x: 0, y: 0, width: 0, height: 0);
			}
			xmin = Double(Int.max)
			xmax = Double(Int.min);
			for site in sites
			{
				if (site.x < xmin)
				{
					xmin = site.x;
				}
				if (site.x > xmax)
				{
					xmax = site.x;
				}
			}
			// here's where we assume that the sites have been sorted on y:
			ymin = sites[0].y;
			ymax = sites[sites.count - 1].y;
			
			return Rectangle(x: xmin, y: ymin, width: xmax - xmin, height: ymax - ymin);
		}

		public func siteColors(/*referenceImage:BitmapData = nil*/)->[UInt]
		{
			var colors = [UInt]()
			for site in sites{
				colors.append(site.color);
			}
			return colors;
		}

		public func siteCoords()->[Point]
		{
			var coords:[Point] = [Point]();
			for site in sites{
				coords.append(site.coord);
			}
			return coords;
		}

		/**
		 * 
		 * @return the largest circle centered at each site that fits in its region;
		 * if the region is infinite, return a circle of radius 0.
		 * 
		 */
		public func circles()->[Circle]
		{
			var circles = [Circle]();
            for site in sites{
				var radius:Double = 0;
				var nearestEdge:Edge = site.nearestEdge();
				
                if(!nearestEdge.isPartOfConvexHull()){
                    radius = nearestEdge.sitesDistance() * 0.5;
                }
				circles.append(Circle(centerX: site.x, centerY: site.y, radius: radius));
			}
			return circles;
		}

		public func regions(plotBounds:Rectangle)->[[Point]]
		{
			var regions:[[Point]] = [[Point]]();
			for site in sites{
				regions.append(site.region(plotBounds));
			}
			return regions;
		}

		/**
		 * 
		 * @param proximityMap a BitmapData whose regions are filled with the site index values; see PlanePointsCanvas::fillRegions()
		 * @param x
		 * @param y
		 * @return coordinates of nearest Site to (x, y)
		 * 
		 */
		public func nearestSitePoint(/*proximityMap:BitmapData,*/ x:Double, y:Double)->Point?{
//			var index:uint = proximityMap.getPixel(x, y);
//			if (index > sites.count - 1)
//			{
				return nil;
//			}
//			return sites[index].coord;
		}
}