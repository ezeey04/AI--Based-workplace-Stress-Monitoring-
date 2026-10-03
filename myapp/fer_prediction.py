import cv2
import numpy as np
from fer.fer import FER


detector = FER()


def predict_emotion(image_file):

    image_data = image_file.read()

    image_array = np.frombuffer(
        image_data,
        np.uint8
    )

    image = cv2.imdecode(
        image_array,
        cv2.IMREAD_COLOR
    )

    if image is None:

        return None, 0


    result = detector.detect_emotions(image)


    if len(result) == 0:

        return None, 0


    emotions = result[0]['emotions']


    emotion_name = max(
        emotions,
        key=emotions.get
    )


    score = float(
        emotions[emotion_name]
    )


    return emotion_name, score