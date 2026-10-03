import os
import cv2
import numpy as np
import tensorflow as tf

from django.http import JsonResponse
from django.contrib.auth.models import User

from .models import ThermalStress


# ============================================================
# THERMAL MODEL PATH
# ============================================================

MODEL_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnetb0_stress.keras"


# ============================================================
# SETTINGS
# ============================================================

IMG_SIZE = 160

# Put your actual best validation threshold here.
# If your training output gave another value, replace 0.50.
THRESHOLD = 0.50


# ============================================================
# GLOBAL MODEL
# ============================================================

thermal_model = None


# ============================================================
# LOAD THERMAL MODEL
# ============================================================

def load_thermal_model():

    global thermal_model

    # --------------------------------------------------------
    # Already loaded
    # --------------------------------------------------------

    if thermal_model is not None:

        return thermal_model

    print()
    print("==============================================")
    print("LOADING THERMAL MODEL")
    print("==============================================")

    print()
    print("Model path:")
    print(MODEL_PATH)

    # --------------------------------------------------------
    # Check model file
    # --------------------------------------------------------

    if not os.path.exists(MODEL_PATH):

        print()
        print("THERMAL MODEL FILE NOT FOUND")

        print(MODEL_PATH)

        return None

    # --------------------------------------------------------
    # Load complete Keras model
    # --------------------------------------------------------

    try:

        thermal_model = tf.keras.models.load_model(
            MODEL_PATH,
            compile=False
        )

        print()
        print("==============================================")
        print("THERMAL MODEL LOADED SUCCESSFULLY")
        print("==============================================")

        print()
        print("Input shape:")

        print(
            thermal_model.input_shape
        )

        print()
        print("Output shape:")

        print(
            thermal_model.output_shape
        )

        print()
        print("Number of layers:")

        print(
            len(thermal_model.layers)
        )

        return thermal_model

    except Exception as e:

        print()
        print("==============================================")
        print("THERMAL MODEL LOAD ERROR")
        print("==============================================")

        print()
        print(str(e))

        print()

        thermal_model = None

        return None


# ============================================================
# PREPROCESS THERMAL IMAGE
# ============================================================

def preprocess_thermal_frame(frame):

    # --------------------------------------------------------
    # Resize
    # --------------------------------------------------------

    frame = cv2.resize(
        frame,
        (
            IMG_SIZE,
            IMG_SIZE
        )
    )

    # --------------------------------------------------------
    # Convert to float32
    # --------------------------------------------------------

    frame = frame.astype(
        np.float32
    )

    # --------------------------------------------------------
    # Min-max normalization
    # --------------------------------------------------------

    image_min = np.min(
        frame
    )

    image_max = np.max(
        frame
    )

    if image_max > image_min:

        frame = (
            frame - image_min
        ) / (
            image_max - image_min
        )

    else:

        frame = frame / 255.0

    # --------------------------------------------------------
    # Add batch dimension
    # --------------------------------------------------------

    frame = np.expand_dims(
        frame,
        axis=0
    )

    return frame


# ============================================================
# PREDICT THERMAL STRESS
# ============================================================

def predict_thermal_stress(frame):

    # --------------------------------------------------------
    # Load model
    # --------------------------------------------------------

    model = load_thermal_model()

    if model is None:

        return (
            None,
            None,
            "Thermal model could not be loaded"
        )

    try:

        # ----------------------------------------------------
        # Convert BGR to RGB
        # ----------------------------------------------------

        frame = cv2.cvtColor(
            frame,
            cv2.COLOR_BGR2RGB
        )

        # ----------------------------------------------------
        # Preprocess
        # ----------------------------------------------------

        image = preprocess_thermal_frame(
            frame
        )

        # ----------------------------------------------------
        # Prediction
        # ----------------------------------------------------

        prediction = model.predict(
            image,
            verbose=0
        )

        # ----------------------------------------------------
        # Get score
        # ----------------------------------------------------

        score = float(
            prediction[0][0]
        )

        # ----------------------------------------------------
        # Stress classification
        # ----------------------------------------------------

        if score >= THRESHOLD:

            status = "STRESS"

        else:

            status = "NON-STRESS"

        print()
        print("==============================================")
        print("THERMAL PREDICTION")
        print("==============================================")

        print()
        print("Stress status:")

        print(
            status
        )

        print()
        print("Stress score:")

        print(
            score
        )

        print()

        return (
            status,
            score,
            None
        )

    except Exception as e:

        print()
        print("==============================================")
        print("THERMAL PREDICTION ERROR")
        print("==============================================")

        print()
        print(str(e))

        return (
            None,
            None,
            str(e)
        )


# ============================================================
# MOBILE THERMAL PREDICTION
# ============================================================

def mobilethermalpredict_post(request):

    # ========================================================
    # CHECK REQUEST METHOD
    # ========================================================

    if request.method != "POST":

        return JsonResponse({

            'status': 'error',

            'message':
                'POST method required'

        })


    # ========================================================
    # GET USER ID
    # ========================================================

    lid = request.POST.get(
        'lid'
    )

    if not lid:

        return JsonResponse({

            'status': 'error',

            'message':
                'lid is required'

        })


    # ========================================================
    # CHECK IMAGE
    # ========================================================

    if 'image' not in request.FILES:

        return JsonResponse({

            'status': 'error',

            'message':
                'image is required'

        })


    try:

        # ====================================================
        # GET USER
        # ====================================================

        user = User.objects.get(
            id=lid
        )


        # ====================================================
        # GET IMAGE
        # ====================================================

        image_file = request.FILES[
            'image'
        ]


        # ====================================================
        # READ IMAGE
        # ====================================================

        image_bytes = image_file.read()


        image_array = np.frombuffer(
            image_bytes,
            np.uint8
        )


        frame = cv2.imdecode(
            image_array,
            cv2.IMREAD_COLOR
        )


        # ====================================================
        # CHECK IMAGE
        # ====================================================

        if frame is None:

            return JsonResponse({

                'status': 'error',

                'message':
                    'Invalid image'

            })


        # ====================================================
        # PREDICT
        # ====================================================

        stress_status, score, error = \
            predict_thermal_stress(
                frame
            )


        # ====================================================
        # CHECK MODEL ERROR
        # ====================================================

        if error:

            return JsonResponse({

                'status': 'error',

                'message':
                    error

            })


        # ====================================================
        # SAVE THERMAL RESULT
        # ====================================================

        obj = ThermalStress()

        obj.stress_status = stress_status

        obj.score = score

        obj.LOGIN = user

        obj.save()


        # ====================================================
        # RESPONSE
        # ====================================================

        return JsonResponse({

            'status':
                'ok',

            'stress_status':
                stress_status,

            'score':
                score

        })


    # ========================================================
    # USER NOT FOUND
    # ========================================================

    except User.DoesNotExist:

        return JsonResponse({

            'status':
                'error',

            'message':
                'User not found'

        })


    # ========================================================
    # OTHER ERROR
    # ========================================================

    except Exception as e:

        print()
        print("==============================================")
        print("THERMAL API ERROR")
        print("==============================================")

        print()
        print(str(e))


        return JsonResponse({

            'status':
                'error',

            'message':
                str(e)

        })