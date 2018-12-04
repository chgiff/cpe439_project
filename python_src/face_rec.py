import pygame
import pygame.camera
import face_recognition
import time
import sys

def wait_for_face(ref_img_path, callback):
	pygame.camera.init()
	cam = pygame.camera.Camera("/dev/video0",(320,240))
	cam.start()
	print("Camera init done")


	# Load a sample picture and learn how to recognize it.
	reference_img = face_recognition.load_image_file(ref_img_path)
	reference_encoding = face_recognition.face_encodings(reference_img)
	print("Encoded ref image")
	if(len(reference_encoding) == 0):
		print("Reference image has no face")
		exit(1)


	while True:
		img = cam.get_image()
		pygame.image.save(img,".tmp.jpg")
		#print("Got image")

		cur_img = face_recognition.load_image_file(".tmp.jpg")
		cur_encoding = face_recognition.face_encodings(cur_img)
		if len(cur_encoding) == 0:
			continue

		if face_recognition.compare_faces(reference_encoding, cur_encoding[0]):
			callback()


def found():
	print("Found face")

def main():
	if len(sys.argv) < 2:
		print("Usage: python face_rec.py <reference image>")
		exit(1)
	wait_for_face(sys.argv[1], found)

if __name__ == '__main__':
	main()
