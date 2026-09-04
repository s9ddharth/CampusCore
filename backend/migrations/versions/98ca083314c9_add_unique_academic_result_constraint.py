"""add unique academic result constraint

Revision ID: 98ca083314c9
Revises: fb503ebdb8a1
Create Date: 2026-09-05 01:22:51.105829

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '98ca083314c9'
down_revision: Union[str, Sequence[str], None] = 'fb503ebdb8a1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
