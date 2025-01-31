from unittest import TestCase
from unittest.mock import MagicMock, patch

from ToDeleteTrigger import delete_blob_and_container_if_last_blob


class TestToDeleteTrigger(TestCase):
    @patch("ToDeleteTrigger.BlobServiceClient")
    def test_delete_blob_and_container_if_last_blob_deletes_container(self, mock_blob_service_client):
        blob_url = "https://stalimextest.blob.core.windows.net/c144728c-3c69-4a58-afec-48c2ec8bfd45/test_dataset.txt"

        mock_blob_service_client().get_container_client().list_blobs = MagicMock(return_value=["blob"])

        delete_blob_and_container_if_last_blob(blob_url)

        mock_blob_service_client().get_container_client().delete_container.assert_called_once()

    @patch("ToDeleteTrigger.BlobServiceClient")
    def test_delete_blob_and_container_if_last_blob_doesnt_delete_container(self, mock_blob_service_client):
        blob_url = "https://stalimextest.blob.core.windows.net/c144728c-3c69-4a58-afec-48c2ec8bfd45/test_dataset.txt"

        mock_blob_service_client().get_container_client().list_blobs = MagicMock(return_value=["blob1", "blob2"])

        delete_blob_and_container_if_last_blob(blob_url)

        mock_blob_service_client().get_container_client().delete_container.assert_not_called()
