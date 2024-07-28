import tensorflow as tf

tfk = tf.keras


class AutoEncoder(tfk.models.Model):
    """
    Standard autoencoder, inherits from the tensorflow keras Model-class
    """

    def __init__(self,
                 latent_dim,
                 filename="./models/autoencoder_weights") -> None:
        super(AutoEncoder, self).__init__()

        self.latent_dim = latent_dim
        self.filename = filename

        # The encoder
        self.encoder = tf.keras.Sequential([
            tfk.layers.Input(shape=(28, 28, 1)),
            tfk.layers.Conv2D(64, (3, 3),
                              activation=tf.nn.leaky_relu,
                              padding='same',
                              strides=2),
            tfk.layers.Conv2D(32, (3, 3),
                              activation=tf.nn.leaky_relu,
                              padding='same',
                              strides=2),
            tfk.layers.Flatten(),
            tfk.layers.Dense(256, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(128, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(64, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(32, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(16, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(latent_dim, activation=tf.nn.leaky_relu)
        ])

        # The decoder
        self.decoder = tf.keras.Sequential([
            tfk.layers.InputLayer(input_shape=(latent_dim, )),
            tfk.layers.Dense(16, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(32, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(64, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(128, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(256, activation=tf.nn.leaky_relu),
            tfk.layers.Dense(7 * 7 * 16, activation=tf.nn.leaky_relu),
            tfk.layers.Reshape((7, 7, 16)),
            tfk.layers.Conv2DTranspose(32,
                                       kernel_size=3,
                                       strides=2,
                                       activation=tf.nn.leaky_relu,
                                       padding='same'),
            tfk.layers.Conv2DTranspose(64,
                                       kernel_size=3,
                                       strides=2,
                                       activation=tf.nn.leaky_relu,
                                       padding='same'),
            tfk.layers.Conv2D(1,
                              kernel_size=(3, 3),
                              activation='sigmoid',
                              padding='same')
        ])

        # Compiling the autoencoder, with binary-cross entropy as loss function
        self.compile(optimizer='adam', loss=tfk.losses.BinaryCrossentropy())

    def call(self, x):
        """
        The call function through the autoencoder
        """
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded

    def load_autoencoder_weights(self):
        """
        Loading weights from file (if it is possible)
        """
        try:
            self.load_weights(filepath=self.filename)
            print(f"Read model from file, so I do not retrain")
            done_training = True

        except:
            print(
                f"Could not read weights for verification_net from file. Must retrain..."
            )
            done_training = False

        return done_training

    def train(self,
              x=None,
              y=None,
              batch_size=None,
              epochs=1,
              shuffle=True,
              validation_data=None,
              verbose=True,
              save_weights=False):
        """
        Training the autoencoder
        """

        # Attempting to weights from previously trained network
        self.done_training = self.load_autoencoder_weights()

        if save_weights or not self.done_training:

            # Training the autoencoder
            self.fit(x=x,
                     y=y,
                     batch_size=batch_size,
                     epochs=epochs,
                     shuffle=shuffle,
                     validation_data=validation_data,
                     verbose=verbose)

            # Save weights and leave
            self.save_weights(filepath=self.filename)
            self.done_training = True

        return self.done_training
