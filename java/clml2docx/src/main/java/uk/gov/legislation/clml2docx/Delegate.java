package uk.gov.legislation.clml2docx;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Map;

import javax.imageio.ImageIO;

public interface Delegate {
	
	public Resource fetch(String uri) throws IOException;

	public default Resource fetch(String uri, Map<String, Resource> cache) throws IOException {
		if (cache.containsKey(uri))
			return cache.get(uri);
		Resource resource = fetch(uri);
		cache.put(uri, resource);
		return resource;
	}

	public static class Resource {
		
		public final byte[] content;
		
		public final String contentType;
		
		public Resource(byte[] data, String contentType) {
			this.content = data;
			this.contentType = contentType;
		}
		
		private BufferedImage image;
		
		int getImageWidth() throws IOException {
			if (image == null)
				image = ImageIO.read(new ByteArrayInputStream(content));
			return image.getWidth();
		}
		
		int getImageHeight() throws IOException {
			if (image == null)
				image = ImageIO.read(new ByteArrayInputStream(content));
			return image.getHeight();
		}
		
	}

}
