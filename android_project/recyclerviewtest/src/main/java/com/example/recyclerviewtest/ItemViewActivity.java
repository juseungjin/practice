package com.example.recyclerviewtest;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.Image;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;

/**
 * Created by seungjin.ju on 2016-05-11.
 */
public class ItemViewActivity extends AppCompatActivity {

    private ImageView imageView;
    private TextView tvName;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.item_view);

        imageView = (ImageView) findViewById(R.id.selected_image);
        tvName = (TextView) findViewById(R.id.image_name);
    }

    @Override
    protected void onResume(){
        super.onResume();
        BitmapFactory.Options opt = new BitmapFactory.Options();
        opt.inSampleSize = 2;
        Bitmap bm = BitmapFactory.decodeFile(getIntent().getStringExtra("ImagePath"), opt);

        imageView.setImageBitmap(bm);
        Log.d("ItemViewActivity", getIntent().getStringExtra("ImageName"));
        tvName.setText(getIntent().getStringExtra("ImageName"));
    }
}
