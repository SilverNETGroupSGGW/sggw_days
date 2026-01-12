// Request body types for creating/updating resources
export interface CreateTreasurePointRequest {
  name: string;
  description: string;
  latitude: number;
  longitude: number;
  qrCode: string;
}

export interface CreateTimetableEventRequest {
  title: string;
  description: string;
  startTime: string;
  endTime: string;
  location: string;
  imageUrl?: string | null;
  tags?: string[];
}

export interface CreateWikiArticleRequest {
  title: string;
  content: string;
  category: string;
  imageUrl?: string | null;
  tags?: string[];
}
