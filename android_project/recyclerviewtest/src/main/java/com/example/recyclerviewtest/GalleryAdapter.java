package com.example.recyclerviewtest;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;

/**
 * Created by seungjin.ju on 2016-05-11.
 */
public class GalleryAdapter extends RecyclerView.Adapter<GalleryAdapter.GalleryViewHolder>{
    private static final String TAG = GalleryAdapter.class.getSimpleName();

    private RecyclerView recyclerView;
    private ArrayList<String> imagePaths = new ArrayList<String>();
    private ArrayList<String> imageName = new ArrayList<String>();
    private int measureWidth;
    private Context mContext;

    public GalleryAdapter(Context _context){
        mContext = _context;
    }

    @Override
    public GalleryViewHolder onCreateViewHolder(ViewGroup parent, int viewType){
        View listItem = LayoutInflater
                .from(parent.getContext())
                .inflate(R.layout.list_item, parent, false);
        return new GalleryViewHolder(listItem);
    }

    @Override
    public int getItemCount(){
        return imagePaths.size();
    }

    @Override
    public void onBindViewHolder(GalleryViewHolder holder, int position){
        BitmapFactory.Options opt = new BitmapFactory.Options();
        opt.inSampleSize = 16;
        Bitmap bm = BitmapFactory.decodeFile(imagePaths.get(position), opt);

        holder.mPosition = position;
        holder.ivImage.setImageBitmap(bm);
        holder.tvTitle.setText(String.format("%s, (%dx%d)", imageName.get(position),
                bm.getWidth(), bm.getHeight()));

        if (measureWidth == 0){
            holder.itemView.post(new ImageViewHeightAdjuster(holder, bm));
        }
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView _recyclerView){
        recyclerView = _recyclerView;
        Utils.collectPicturesInfo(recyclerView.getContext(), imagePaths, imageName);
    }

    class ImageViewHeightAdjuster implements  Runnable{
        GalleryViewHolder holder;
        int width;
        int height;

        public ImageViewHeightAdjuster(GalleryViewHolder _holder, Bitmap bm){
            holder = _holder;
            _holder.setIsRecyclable(false);

            width = bm.getWidth();
            height = bm.getHeight();
        }
        @Override
        public void run(){
            measureWidth = holder.itemView.getWidth();

            double ratio = (double) height/width;
            holder.ivImage.setMinimumHeight((int)(measureWidth * ratio));
            holder.setIsRecyclable(true);
        }
    }

    class GalleryViewHolder extends RecyclerView.ViewHolder{
        ImageView ivImage;
        TextView tvTitle;
        int mPosition;

        public GalleryViewHolder(final View listItem){
            super(listItem);

            ivImage = (ImageView)listItem.findViewById(R.id.image);
            tvTitle = (TextView) listItem.findViewById(R.id.title);
            listItem.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //Toast.makeText(listItem.getContext(), "Select Image !!" , Toast.LENGTH_SHORT);
                    Intent intent = new Intent(listItem.getContext(),ItemViewActivity.class);
                    intent.putExtra("ImagePath",imagePaths.get(mPosition));
                    intent.putExtra("ImageName",tvTitle.getText());
                    Log.d("GalleryViewHolder","image path = " + imagePaths.get(mPosition));
                    mContext.startActivity(intent);
                }
            });
        }
    }
}
